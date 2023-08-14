import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/metric_rule.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A global state rule which forbids using variables
/// that can be globally modified.
class AvoidGlobalStateRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use global state.
  static const lintName = 'avoid_global_state';

  AvoidGlobalStateRule._(super.config);

  /// Creates a new instance of [AvoidGlobalStateRule]
  /// based on the lint configuration.
  factory AvoidGlobalStateRule.createRule(CustomLintConfigs configs) {
    final rule = MetricRule(
      configs: configs,
      name: lintName,
      problemMessage: (_) => 'Avoid variables that can be globally mutated.',
    );

    return AvoidGlobalStateRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      final isPrivate = node.declaredElement?.isPrivate ?? false;

      if (!isPrivate && !node.isFinal && !node.isConst) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
