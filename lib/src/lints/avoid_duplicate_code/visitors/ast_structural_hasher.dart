import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A [RecursiveAstVisitor] that builds a structural fingerprint of an AST
/// subtree for clone detection.
///
/// The fingerprint captures the structure of the code (node types, operators,
/// and optionally literal values) while ignoring identifier names, whitespace,
/// and comments. This enables Type 2 clone detection where two code blocks
/// with identical structure but different variable names are considered clones.
class AstStructuralHasher extends RecursiveAstVisitor<void> {
  final bool _ignoreLiterals;
  final bool _ignoreIdentifiers;
  final StringBuffer _buffer = StringBuffer();

  /// Creates a new [AstStructuralHasher].
  AstStructuralHasher({
    required bool ignoreLiterals,
    required bool ignoreIdentifiers,
  })  : _ignoreLiterals = ignoreLiterals,
        _ignoreIdentifiers = ignoreIdentifiers;

  /// Computes the structural hash for the given [node].
  ///
  /// Visits the entire subtree of [node] and returns an integer hash
  /// of the accumulated structural fingerprint.
  int computeHash(AstNode node) {
    _buffer.clear();
    node.accept(this);
    return _buffer.toString().hashCode;
  }

  /// Returns the raw structural fingerprint string for the given [node].
  ///
  /// Useful for debugging and testing.
  String computeFingerprint(AstNode node) {
    _buffer.clear();
    node.accept(this);
    return _buffer.toString();
  }

  // --- Structure nodes ---

  @override
  void visitBlock(Block node) {
    _append('Block');
    super.visitBlock(node);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _append('BlockFunctionBody');
    super.visitBlockFunctionBody(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _append('ExpressionFunctionBody');
    super.visitExpressionFunctionBody(node);
  }

  // --- Statements ---

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    _append('ExpressionStatement');
    super.visitExpressionStatement(node);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    _append('ReturnStatement');
    super.visitReturnStatement(node);
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    _append('VariableDeclarationStatement');
    // Include keyword (final/var/const)
    final keyword = node.variables.keyword;
    if (keyword != null) {
      _append(keyword.lexeme);
    }
    super.visitVariableDeclarationStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _append('IfStatement');
    _append(node.elseKeyword != null ? 'withElse' : 'noElse');
    super.visitIfStatement(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _append('ForStatement');
    super.visitForStatement(node);
  }

  @override
  void visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    _append('ForEachPartsWithDeclaration');
    super.visitForEachPartsWithDeclaration(node);
  }

  @override
  void visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    _append('ForPartsWithDeclarations');
    super.visitForPartsWithDeclarations(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _append('WhileStatement');
    super.visitWhileStatement(node);
  }

  @override
  void visitDoStatement(DoStatement node) {
    _append('DoStatement');
    super.visitDoStatement(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _append('SwitchStatement');
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _append('SwitchCase');
    super.visitSwitchCase(node);
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _append('SwitchDefault');
    super.visitSwitchDefault(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    _append('SwitchExpression');
    super.visitSwitchExpression(node);
  }

  @override
  void visitSwitchExpressionCase(SwitchExpressionCase node) {
    _append('SwitchExpressionCase');
    super.visitSwitchExpressionCase(node);
  }

  @override
  void visitTryStatement(TryStatement node) {
    _append('TryStatement');
    _append(node.finallyBlock != null ? 'withFinally' : 'noFinally');
    super.visitTryStatement(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _append('CatchClause');
    super.visitCatchClause(node);
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    _append('ThrowExpression');
    super.visitThrowExpression(node);
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    _append('BreakStatement');
    super.visitBreakStatement(node);
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    _append('ContinueStatement');
    super.visitContinueStatement(node);
  }

  @override
  void visitAssertStatement(AssertStatement node) {
    _append('AssertStatement');
    super.visitAssertStatement(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _append('YieldStatement');
    _append(node.star != null ? 'star' : 'noStar');
    super.visitYieldStatement(node);
  }

  // --- Expressions ---

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _append('BinaryExpression');
    _append(node.operator.type.toString());
    super.visitBinaryExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _append('PrefixExpression');
    _append(node.operator.type.toString());
    super.visitPrefixExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _append('PostfixExpression');
    _append(node.operator.type.toString());
    super.visitPostfixExpression(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _append('AssignmentExpression');
    _append(node.operator.type.toString());
    super.visitAssignmentExpression(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _append('ConditionalExpression');
    super.visitConditionalExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _append('MethodInvocation');
    // Include method name as it's part of the API being called,
    // not a local identifier
    _append(node.methodName.name);
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _append('FunctionExpressionInvocation');
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _append('InstanceCreationExpression');
    _append(node.constructorName.type.name.lexeme);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _append('PropertyAccess');
    _append(node.propertyName.name);
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _append('PrefixedIdentifier');
    // Include the property name, but not the prefix (which is a local variable)
    _append(node.identifier.name);
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _append('IndexExpression');
    super.visitIndexExpression(node);
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    _append('CascadeExpression');
    super.visitCascadeExpression(node);
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    _append('AwaitExpression');
    super.visitAwaitExpression(node);
  }

  @override
  void visitAsExpression(AsExpression node) {
    _append('AsExpression');
    super.visitAsExpression(node);
  }

  @override
  void visitIsExpression(IsExpression node) {
    _append('IsExpression');
    _append(node.notOperator != null ? 'not' : 'is');
    super.visitIsExpression(node);
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    _append('ParenthesizedExpression');
    super.visitParenthesizedExpression(node);
  }

  @override
  void visitListLiteral(ListLiteral node) {
    _append('ListLiteral');
    super.visitListLiteral(node);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _append('SetOrMapLiteral');
    super.visitSetOrMapLiteral(node);
  }

  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    _append('MapLiteralEntry');
    super.visitMapLiteralEntry(node);
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    _append('SpreadElement');
    super.visitSpreadElement(node);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    _append('NamedExpression');
    _append(node.name.label.name);
    super.visitNamedExpression(node);
  }

  // --- Literals ---

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _append('IntegerLiteral');
    if (!_ignoreLiterals) {
      _append(node.literal.lexeme);
    }
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    _append('DoubleLiteral');
    if (!_ignoreLiterals) {
      _append(node.literal.lexeme);
    }
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _append('StringLiteral');
    if (!_ignoreLiterals) {
      _append(node.value);
    }
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _append('StringInterpolation');
    super.visitStringInterpolation(node);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    _append('BooleanLiteral');
    if (!_ignoreLiterals) {
      _append(node.value.toString());
    }
  }

  @override
  void visitNullLiteral(NullLiteral node) {
    _append('NullLiteral');
  }

  // --- Identifiers (ignored for Type 2 clone detection) ---

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _append('Identifier');
    if (!_ignoreIdentifiers) {
      _append(node.name);
    }
  }

  // --- Type annotations ---

  @override
  void visitNamedType(NamedType node) {
    _append('NamedType');
    _append(node.name.lexeme);
    super.visitNamedType(node);
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    _append('GenericFunctionType');
    super.visitGenericFunctionType(node);
  }

  // --- Variable declarations ---

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _append('VariableDeclaration');
    super.visitVariableDeclaration(node);
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    _append('VariableDeclarationList');
    super.visitVariableDeclarationList(node);
  }

  // --- Arguments and parameters ---

  @override
  void visitArgumentList(ArgumentList node) {
    _append('ArgumentList');
    _append(node.arguments.length.toString());
    super.visitArgumentList(node);
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    _append('FormalParameterList');
    super.visitFormalParameterList(node);
  }

  // --- Function expressions (closures) ---

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _append('FunctionExpression');
    super.visitFunctionExpression(node);
  }

  // --- Type arguments ---

  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    _append('TypeArgumentList');
    super.visitTypeArgumentList(node);
  }

  // --- Null-aware operators ---

  @override
  void visitNullCheckPattern(NullCheckPattern node) {
    _append('NullCheckPattern');
    super.visitNullCheckPattern(node);
  }

  @override
  void visitNullAssertPattern(NullAssertPattern node) {
    _append('NullAssertPattern');
    super.visitNullAssertPattern(node);
  }

  void _append(String value) {
    _buffer.write(value);
    _buffer.write('|');
  }
}
