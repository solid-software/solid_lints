import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_unrelated_type_assertions/avoid_unrelated_type_assertions_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `avoid_unrelated_type_assertions` rule which
/// warns about unnecessary usage of `as` operator
class AvoidUnrelatedTypeAssertionsRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid_unrelated_type_assertions';

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
          'Avoid unrelated "is" assertion. The result is always "{0}".',
    );

    return AvoidUnrelatedTypeAssertionsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIsExpression((node) {
      final visitor = AvoidUnrelatedTypeAssertionsVisitor();
      visitor.visitIsExpression(node);

      for (final element in visitor.expressions.entries) {
        reporter.reportErrorForNode(
          code,
          element.key,
          [element.value.toString()],
        );
      }
    });
  }
}
