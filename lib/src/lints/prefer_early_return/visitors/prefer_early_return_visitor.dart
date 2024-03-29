import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/return_statement_visitor.dart';

/// The AST visitor that will collect all unnecessary if statements
class PreferEarlyReturnVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];

  /// All unnecessary if statements and conditional expressions.
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    super.visitBlockFunctionBody(node);

    if (node.block.statements.isEmpty) return;

    final (ifStatements, nextStatement) = _getStartIfStatements(node);
    if (ifStatements.isEmpty) return;

    // limit visitor to only work with functions
    // that don't have a return statement or the return statementis empty
    final nextStatementIsEmptyReturn =
        nextStatement is ReturnStatement && nextStatement.expression == null;
    final nextStatementIsNull = nextStatement == null;

    if (!(nextStatementIsEmptyReturn || nextStatementIsNull)) return;

    _handleIfStatement(ifStatements.last);
  }

  void _handleIfStatement(IfStatement node) {
    if (_isElseIfStatement(node)) return;
    if (_hasElseStatement(node)) return;
    if (_hasReturnStatement(node)) return;

    _nodes.add(node);
  }
}

// returns a list of if statements at the start of the function
// and the next statement after it
// examples:
// [if, if, if, return] -> ([if, if, if], return)
// [if, if, if, _doSomething, return] -> ([if, if, if], _doSomething)
// [if, if, if] -> ([if, if, if], null)
(List<IfStatement>, Statement?) _getStartIfStatements(BlockFunctionBody body) {
  final List<IfStatement> ifStatements = [];
  for (final statement in body.block.statements) {
    if (statement is IfStatement) {
      ifStatements.add(statement);
    } else {
      return (ifStatements, statement);
    }
  }
  return (ifStatements, null);
}

bool _hasElseStatement(IfStatement node) {
  return node.elseStatement != null;
}

bool _isElseIfStatement(IfStatement node) {
  return node.elseStatement != null && node.elseStatement is IfStatement;
}

bool _hasReturnStatement(Statement node) {
  final visitor = ReturnStatementVisitor();
  node.accept(visitor);
  return visitor.nodes.isNotEmpty;
}
