import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/jenkins_hasher.dart';

/// A [UnifyingAstVisitor] that builds a structural fingerprint of an AST
/// subtree for clone detection.
///
/// The fingerprint captures the structure of the code (node types, operators,
/// and optionally literal values) while ignoring identifier names (like local
/// variables), whitespace, and comments. This enables Type 2 clone detection
/// where two code blocks with identical structure but different variable names
/// are considered clones.
class AstStructuralHashVisitor extends UnifyingAstVisitor<void> {
  final JenkinsHasher _hasher = JenkinsHasher();

  final bool _ignoreLiterals;
  final bool _ignoreIdentifiers;
  final Map<Element, int> _localVariableIds = {};

  /// Creates a new [AstStructuralHashVisitor].
  AstStructuralHashVisitor({
    required bool ignoreLiterals,
    required bool ignoreIdentifiers,
  }) : _ignoreLiterals = ignoreLiterals,
       _ignoreIdentifiers = ignoreIdentifiers;

  /// Computes the structural hash for the given [node].
  ///
  /// Visits the entire subtree of [node] and returns an integer hash
  /// of the accumulated structural fingerprint.
  int computeHash(AstNode node) {
    _hasher.reset();
    _localVariableIds.clear();
    node.accept(this);
    return _hasher.hash;
  }

  void _append(String value) {
    _hasher.addString(value);
    _hasher.add(0x7C); // ASCII code for '|'
  }

  void _appendHash(int hashCode) {
    _hasher.add(hashCode);
    _hasher.add(0x7C); // ASCII code for '|'
  }

  @override
  void visitNode(AstNode node) {
    _appendHash(node.runtimeType.hashCode);
    node.visitChildren(this);
    _append('^');
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    final keyword = node.variables.keyword;
    if (keyword != null) {
      _append(keyword.lexeme);
    }
    super.visitVariableDeclarationStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _appendHash(node.elseKeyword != null ? 1 : 0);
    super.visitIfStatement(node);
  }

  @override
  void visitTryStatement(TryStatement node) {
    _appendHash(node.finallyBlock != null ? 1 : 0);
    super.visitTryStatement(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _appendHash(node.star != null ? 1 : 0);
    super.visitYieldStatement(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _appendHash(node.operator.type.hashCode);
    super.visitBinaryExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (_ignoreLiterals &&
        (node.operator.type == TokenType.MINUS ||
            node.operator.type == TokenType.PLUS) &&
        (node.operand is IntegerLiteral || node.operand is DoubleLiteral)) {
      node.operand.accept(this);
      return;
    }
    _appendHash(node.operator.type.hashCode);
    super.visitPrefixExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _appendHash(node.operator.type.hashCode);
    super.visitPostfixExpression(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _appendHash(node.operator.type.hashCode);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitIsExpression(IsExpression node) {
    _appendHash(node.notOperator != null ? 1 : 0);
    super.visitIsExpression(node);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    _append(node.name.label.name);
    super.visitNamedExpression(node);
  }

  // --- Literals ---

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    if (!_ignoreLiterals) {
      _append(node.literal.lexeme);
    }
    super.visitIntegerLiteral(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    if (!_ignoreLiterals) {
      _append(node.literal.lexeme);
    }
    super.visitDoubleLiteral(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (!_ignoreLiterals) {
      _append(node.value);
    }
    super.visitSimpleStringLiteral(node);
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    if (!_ignoreLiterals) {
      _append(node.value);
    }
    super.visitInterpolationString(node);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    if (!_ignoreLiterals) {
      _appendHash(node.value ? 1 : 0);
    }
    super.visitBooleanLiteral(node);
  }

  // --- Identifiers ---

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!_ignoreIdentifiers) {
      _append(node.name);
    } else {
      // Smart ignore: ignore ONLY local variables and parameters.
      // This preserves field names, getters, methods, class names, etc.
      final element = node.element;
      if (element != null) {
        if (element is LocalVariableElement ||
            element is FormalParameterElement) {
          // It is a local variable or parameter.
          // Assign it a local ID (De Bruijn Indexing) to distinguish clones
          // that wire their variables differently.
          final id = _localVariableIds.putIfAbsent(
            element,
            () => _localVariableIds.length,
          );
          _appendHash(id);
        } else {
          _append(node.name);
        }
      }
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitNamedType(NamedType node) {
    _append(node.name.lexeme);
    super.visitNamedType(node);
  }
}
