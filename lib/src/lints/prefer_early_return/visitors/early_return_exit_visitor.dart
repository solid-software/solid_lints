import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// AST visitor that checks if a statement contains an early exit
/// (return, throw, or loop break/continue) respecting scope boundaries.
class EarlyReturnExitVisitor extends RecursiveAstVisitor<void> {
  final bool _isLoop;
  bool _hasExit = false;
  int _nestedLoopDepth = 0;
  int _nestedSwitchDepth = 0;

  EarlyReturnExitVisitor._(this._isLoop);

  /// Checks whether [node] contains any early exit statement.
  static bool hasExitIn(Statement node, {required bool isLoop}) {
    final visitor = EarlyReturnExitVisitor._(isLoop);
    node.accept(visitor);
    return visitor._hasExit;
  }

  @override
  void visitReturnStatement(ReturnStatement node) => _hasExit = true;

  @override
  void visitThrowExpression(ThrowExpression node) => _hasExit = true;

  @override
  void visitBreakStatement(BreakStatement node) {
    if (_isLoop && _nestedLoopDepth == 0 && _nestedSwitchDepth == 0) {
      _hasExit = true;
    }
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    if (_isLoop && _nestedLoopDepth == 0) {
      _hasExit = true;
    }
  }

  @override
  void visitForStatement(ForStatement node) =>
      _withNestedLoop(() => super.visitForStatement(node));

  @override
  void visitWhileStatement(WhileStatement node) =>
      _withNestedLoop(() => super.visitWhileStatement(node));

  @override
  void visitDoStatement(DoStatement node) =>
      _withNestedLoop(() => super.visitDoStatement(node));

  @override
  void visitSwitchStatement(SwitchStatement node) =>
      _withNestedSwitch(() => super.visitSwitchStatement(node));

  @override
  void visitFunctionExpression(FunctionExpression node) {}

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {}

  void _withNestedLoop(void Function() visit) {
    _nestedLoopDepth++;
    visit();
    _nestedLoopDepth--;
  }

  void _withNestedSwitch(void Function() visit) {
    _nestedSwitchDepth++;
    visit();
    _nestedSwitchDepth--;
  }
}
