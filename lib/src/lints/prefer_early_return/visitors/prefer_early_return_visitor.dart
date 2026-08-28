import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_early_return/models/prefer_early_return_parameters.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/early_return_exit_visitor.dart';

/// Visitor for [PreferEarlyReturnRule].
class PreferEarlyReturnVisitor extends SimpleAstVisitor<void> {
  /// The rule associated with the visitor.
  final PreferEarlyReturnRule rule;

  /// The context associated with the visitor.
  final RuleContext context;

  /// The parameters associated with the rule.
  final PreferEarlyReturnParameters parameters;

  /// Constructor for [PreferEarlyReturnVisitor].
  PreferEarlyReturnVisitor({
    required this.rule,
    required this.context,
    required this.parameters,
  });

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) =>
      _checkStatements(node.block.statements, isLoop: false);

  @override
  void visitForStatement(ForStatement node) => _checkLoopBody(node.body);

  @override
  void visitWhileStatement(WhileStatement node) => _checkLoopBody(node.body);

  @override
  void visitDoStatement(DoStatement node) => _checkLoopBody(node.body);

  void _checkLoopBody(Statement body) {
    final List<Statement> statements = switch (body) {
      Block(:final statements) => statements,
      IfStatement() => [body],
      _ => const [],
    };

    if (statements.isNotEmpty) {
      _checkStatements(statements, isLoop: true);
    }
  }

  void _checkStatements(
    List<Statement> statements, {
    required bool isLoop,
  }) {
    final (leading, lastIf) = switch (statements) {
      [...final leading, IfStatement lastIf] => (leading, lastIf),
      [...final leading, IfStatement lastIf, ContinueStatement(label: null)]
          when isLoop =>
        (leading, lastIf),
      [...final leading, IfStatement lastIf, ReturnStatement(expression: null)]
          when !isLoop =>
        (leading, lastIf),
      _ => (null, null),
    };

    if (lastIf == null || !leading!.every((s) => s is IfStatement)) return;
    if (!_shouldReport(lastIf)) return;

    context.currentUnit?.diagnosticReporter.atNode(
      lastIf,
      rule.diagnosticCode,
    );
  }

  bool _shouldReport(IfStatement ifStatement) {
    final IfStatement(:thenStatement, :elseStatement, :caseClause) =
        ifStatement;

    if (elseStatement != null ||
        (parameters.ignoreIfCase && caseClause != null)) {
      return false;
    }

    final statementsCount = switch (thenStatement) {
      Block(:final statements) => statements.length,
      _ => 1,
    };

    return statementsCount > parameters.maximumStatements &&
        !EarlyReturnExitVisitor.hasExitIn(thenStatement);
  }
}
