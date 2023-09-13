import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_unrelated_type_assertions/avoid_unrelated_type_assertions_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `avoid-unrelated-type-assertions` rule which
/// warns about unnecessary usage of `as` operator
class AvoidUnrelatedTypeAssertionsRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid-unrelated-type-assertions';

  AvoidUnrelatedTypeAssertionsRule._(super.config);

  /// Creates a new instance of [AvoidUnrelatedTypeAssertionsRule]
  /// based on the lint configuration.
  factory AvoidUnrelatedTypeAssertionsRule.createRule(
    CustomLintConfigs configs,
  ) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) =>
          'Avoid unrelated "is" assertion. The result is always "false".',
    );

    return AvoidUnrelatedTypeAssertionsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final visitor = AvoidUnrelatedTypeAssertionsVisitor();

    context.registry.addIsExpression((node) {
      visitor.visitIsExpression(node);

      for (final element in visitor.expressions.entries) {
        reporter.reportErrorForNode(code, element.key);
      }
    });
  }
}
