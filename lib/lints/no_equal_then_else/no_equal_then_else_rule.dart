import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/no_equal_then_else/no_equal_then_else_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

// Inspired by PVS-Studio (https://www.viva64.com/en/w/v6004/)

/// A `no-equal-then-else` rule which warns about
/// unnecessary if statements and conditional expressions
class NoEqualThenElseRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if
  /// 'if' statements or conditional expression is redundant
  static const String lintName = 'no-equal-then-else';

  NoEqualThenElseRule._(super.config);

  /// Creates a new instance of [NoEqualThenElseRule]
  /// based on the lint configuration.
  factory NoEqualThenElseRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) => "Then and else branches are equal.",
    );

    return NoEqualThenElseRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = NoEqualThenElseVisitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
