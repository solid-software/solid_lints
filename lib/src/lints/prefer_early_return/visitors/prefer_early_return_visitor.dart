import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/if_statement_visitor.dart';

/// The AST visitor that will collect all unnecessary if statements
class PreferEarlyReturnVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    super.visitBlockFunctionBody(node);
    if (node.block.statements.isEmpty) return;

    final first = node.block.statements.first;

    switch (node.block.statements.length) {
      case 1:
        if (first is IfStatement) _handleIfStatement(first);
        return;
      case 2:
        final last = node.block.statements.last;
        if (last is ReturnStatement && first is IfStatement) {
          _handleIfStatement(first);
        }
      case _:
        return;
    }
  }

  void _handleIfStatement(IfStatement node) {
    if (_isElseIfStatement(node)) return;
    if (_hasElseStatement(node)) return;
    final containsNestedIfStatement = _containsIfStatement(node.thenStatement);
    if (!containsNestedIfStatement) return;

    _nodes.add(node);
  }
}

bool _hasElseStatement(IfStatement node) {
  return node.elseStatement != null;
}

bool _isElseIfStatement(IfStatement node) {
  return node.elseStatement != null && node.elseStatement is IfStatement;
}

bool _containsIfStatement(Statement node) {
  final visitor = IfStatementVisitor();
  node.accept(visitor);
  return visitor.nodes.isNotEmpty;
}
