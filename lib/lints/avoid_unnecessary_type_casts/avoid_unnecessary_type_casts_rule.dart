import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_unnecessary_type_casts/avoid_unnecessary_type_casts_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `avoid-unnecessary-type-casts` rule which
/// warns about unnecessary usage of `is` and `whereType` operators
class AvoidUnnecessaryTypeCastsRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid-unnecessary-type-casts';

  AvoidUnnecessaryTypeCastsRule._(super.config);

  /// Creates a new instance of [AvoidUnnecessaryTypeCastsRule]
  /// based on the lint configuration.
  factory AvoidUnnecessaryTypeCastsRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => "Avoid unnecessary usage of as operator.",
    );

    return AvoidUnnecessaryTypeCastsRule._(rule);
  }

  @override
  void run(
      CustomLintResolver resolver,
      ErrorReporter reporter,
      CustomLintContext context,
      ) {
    final visitor = AvoidUnnecessaryTypeCastsVisitor();

    context.registry.addAsExpression((node) {
      visitor.visitAsExpression(node);

      for (final element in visitor.expressions.entries) {
        reporter.reportErrorForNode(code, element.key);
      }
    });
  }
}
