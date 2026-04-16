import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';

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
  void visitIfStatement(IfStatement node) {
    if (_shouldReport(node)) {
      context.currentUnit?.diagnosticReporter.atNode(
        node,
        rule.diagnosticCode,
      );
    }

    super.visitIfStatement(node);
  }

  bool _shouldReport(IfStatement node) {
    final parent = node.parent;

    return parent is Block && parent.statements.length == 1;
  }
}
