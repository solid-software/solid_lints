import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/return_statement_visitor.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/throw_expression_visitor.dart';

/// Visitor for [PreferEarlyReturnRule].
class PreferEarlyReturnVisitor extends RecursiveAstVisitor<void> {
  /// The rule associated with the visitor.
  final PreferEarlyReturnRule rule;

  /// The context associated with the visitor.
  final RuleContext context;

  /// Constructor for [PreferEarlyReturnVisitor].
  PreferEarlyReturnVisitor({
    required this.rule,
    required this.context,
  });

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    super.visitBlockFunctionBody(node);

    if (node.block.statements.isEmpty) return;

    final (ifStatements, nextStatement) = _getIfStatementsAndNextStatement(
      node,
    );
    if (ifStatements.isEmpty) return;

    // limit visitor to only work with functions
    // that don't have a return statement or the return statement is empty
    final nextStatementIsEmptyReturn =
        nextStatement is ReturnStatement && nextStatement.expression == null;
    final nextStatementIsNull = nextStatement == null;

    if (!nextStatementIsEmptyReturn && !nextStatementIsNull) return;

    final lastIf = ifStatements.last;

    if (lastIf case IfStatement(elseStatement: Statement())) return;
    if (_hasReturnStatement(lastIf) || _hasThrowExpression(lastIf)) return;

    context.currentUnit?.diagnosticReporter.atNode(
      lastIf,
      rule.diagnosticCode,
    );
  }

  // returns a list of if statements at the start of the function
  // and the next statement after it
  // examples:
  // [if, if, if, return] -> ([if, if, if], return)
  // [if, if, if, _doSomething, return] -> ([if, if, if], _doSomething)
  // [if, if, if] -> ([if, if, if], null)
  (List<IfStatement>, Statement?) _getIfStatementsAndNextStatement(
    BlockFunctionBody body,
  ) {
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

  bool _hasReturnStatement(Statement node) {
    final visitor = ReturnStatementVisitor();
    node.accept(visitor);
    return visitor.nodes.isNotEmpty;
  }

  bool _hasThrowExpression(Statement node) {
    final visitor = ThrowExpressionVisitor();
    node.accept(visitor);
    return visitor.nodes.isNotEmpty;
  }
}
