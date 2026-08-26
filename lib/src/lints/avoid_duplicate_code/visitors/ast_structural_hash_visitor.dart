import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/jenkins_hasher.dart';

/// A [UnifyingAstVisitor] that builds structural and exact fingerprints of an
/// AST subtree for clone detection.
///
/// The structural fingerprint captures the structure of the code (node types,
/// operators, and type annotations) while ignoring identifier names (like
/// local variables), literal values, whitespace, and comments. The exact
/// fingerprint also incorporates literal values. This enables Type 2 and Type 3
/// clone detection where code blocks with identical structure are identified
/// as clones and compared for differing literals.
class AstStructuralHashVisitor extends UnifyingAstVisitor<void> {
  static final _typeNameCache = <Type, String>{};
  static const _pipeAscii = 0x7C; // '|'

  final _structuralHasher = JenkinsHasher();
  final _exactHasher = JenkinsHasher();
  final _localVariableIds = <Element, int>{};

  /// Creates a new [AstStructuralHashVisitor].
  AstStructuralHashVisitor();

  /// Computes both the structural hash (ignoring literal values) and the exact
  /// hash (including literal values) for the given [node].
  ({int structuralHash, int exactHash}) computeHashes(AstNode node) {
    _structuralHasher.reset();
    _exactHasher.reset();
    _localVariableIds.clear();
    node.accept(this);
    return (
      structuralHash: _structuralHasher.hash,
      exactHash: _exactHasher.hash,
    );
  }

  /// Computes the structural hash for the given [node].
  int computeHash(AstNode node) => computeHashes(node).structuralHash;

  void _append(String value) {
    _appendStructural(value);
    _appendExact(value);
  }

  void _appendHash(int hashCode) {
    _appendStructuralHash(hashCode);
    _appendExactHash(hashCode);
  }

  void _appendBool(bool value) => _appendHash(value ? 1 : 0);

  void _appendStructural(String value) => _structuralHasher
    ..addString(value)
    ..add(_pipeAscii);

  void _appendStructuralHash(int hashCode) => _structuralHasher
    ..add(hashCode)
    ..add(_pipeAscii);

  void _appendExact(String value) => _exactHasher
    ..addString(value)
    ..add(_pipeAscii);

  void _appendExactHash(int hashCode) => _exactHasher
    ..add(hashCode)
    ..add(_pipeAscii);

  void _appendExactBool(bool value) => _appendExactHash(value ? 1 : 0);

  @override
  void visitNode(AstNode node) {
    // Use the type name string instead of runtimeType.hashCode, because
    // identity-based hashCode changes between VM/isolate restarts, making
    // hashes stored in the persistent cache incompatible with newly computed
    // ones. This caused "flapping" warnings that appeared and disappeared.
    //
    // The result is cached in a static map to avoid repeated toString()
    // reflection calls during tree traversal.
    final type = node.runtimeType;
    _append(_typeNameCache.putIfAbsent(type, type.toString));
    node.visitChildren(this);
    _append('^');
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    if (node.variables.keyword?.lexeme case final l?) _append(l);
    super.visitVariableDeclarationStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _appendBool(node.elseKeyword != null);
    super.visitIfStatement(node);
  }

  @override
  void visitTryStatement(TryStatement node) {
    _appendBool(node.finallyBlock != null);
    super.visitTryStatement(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _appendBool(node.star != null);
    super.visitYieldStatement(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _append(node.operator.lexeme);
    super.visitBinaryExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    if (node case PrefixExpression(
      operator: Token(type: TokenType.MINUS || TokenType.PLUS, :final lexeme),
      operand: IntegerLiteral() || DoubleLiteral(),
    )) {
      _appendExact(lexeme);
      node.operand.accept(this);

      return;
    }

    _append(node.operator.lexeme);
    super.visitPrefixExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _append(node.operator.lexeme);
    super.visitPostfixExpression(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _append(node.operator.lexeme);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitIsExpression(IsExpression node) {
    _appendBool(node.notOperator != null);
    super.visitIsExpression(node);
  }

  @override
  void visitNamedArgument(NamedArgument node) {
    _append(node.name.lexeme);
    super.visitNamedArgument(node);
  }

  // --- Literals ---

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _appendExact(node.literal.lexeme);
    super.visitIntegerLiteral(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _appendExact(node.literal.lexeme);
    super.visitDoubleLiteral(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _appendExact(node.value);
    super.visitSimpleStringLiteral(node);
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    _appendExact(node.value);
    super.visitInterpolationString(node);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    _appendExactBool(node.value);
    super.visitBooleanLiteral(node);
  }

  @override
  void visitSymbolLiteral(SymbolLiteral node) {
    _appendExact(node.components.map((t) => t.lexeme).join('.'));
    super.visitSymbolLiteral(node);
  }

  // --- Identifiers ---

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final element = node.element;

    switch (element) {
      // Smart ignore: ignore ONLY local variables and parameters.
      // This preserves field names, getters, methods, class names, etc.
      case LocalVariableElement() ||
          FormalParameterElement() ||
          PatternVariableElement():
        // It is a local variable or parameter.
        // Assign it a local ID (De Bruijn Indexing) to distinguish clones
        // that wire their variables differently.
        _appendHash(
          _localVariableIds.putIfAbsent(
            element!,
            () => _localVariableIds.length,
          ),
        );
      default:
        _append(node.name);
    }

    super.visitSimpleIdentifier(node);
  }

  @override
  void visitNamedType(NamedType node) {
    _append(node.name.lexeme);
    super.visitNamedType(node);
  }
}
