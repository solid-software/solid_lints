import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// AST visitor that checks if a statement contains an early exit
/// (return, throw, or loop break/continue) respecting scope boundaries.
class EarlyReturnExitVisitor extends RecursiveAstVisitor<void> {
  final Statement _root;
  bool _hasExit = false;

  EarlyReturnExitVisitor._(this._root);

  /// Checks whether [node] contains any early exit statement.
  static bool hasExitIn(Statement node) {
    final visitor = EarlyReturnExitVisitor._(node);
    node.accept(visitor);
    return visitor._hasExit;
  }

  @override
  void visitReturnStatement(ReturnStatement node) => _hasExit = true;

  @override
  void visitThrowExpression(ThrowExpression node) => _hasExit = true;

  @override
  void visitRethrowExpression(RethrowExpression node) => _hasExit = true;

  @override
  void visitBreakStatement(BreakStatement node) => _checkExit(node.target);

  @override
  void visitContinueStatement(ContinueStatement node) =>
      _checkExit(node.target);

  @override
  void visitFunctionExpression(FunctionExpression node) {}

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {}

  bool _isDescendantOfRoot(AstNode target) {
    AstNode? current = target;
    while (current != null) {
      if (identical(current, _root)) {
        return true;
      }
      current = current.parent;
    }
    return false;
  }

  void _checkExit(AstNode? target) {
    if (target case final target? when !_isDescendantOfRoot(target)) {
      _hasExit = true;
    }
  }
}
