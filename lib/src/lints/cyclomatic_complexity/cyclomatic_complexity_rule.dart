import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/visitors/cyclomatic_complexity_flow_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Limit for the number of linearly independent paths through a program's
/// source code.
///
/// Counts the number of code branches and loop statements within function and
/// method bodies.
///
/// ### Example config:
///
/// This configuration will allow 10 code branchings per function body before
/// triggering a warning.
///
/// ```yaml
/// custom_lint:
///   rules:
///     - cyclomatic_complexity:
///       max_complexity: 10
/// ```
class CyclomaticComplexityRule
    extends SolidLintRule<CyclomaticComplexityParameters> {
  /// The [LintCode] of this lint rule that represents the error if complexity
  /// reaches maximum value.
  static const lintName = 'cyclomatic_complexity';

  CyclomaticComplexityRule._(super.rule);

  /// Creates a new instance of [CyclomaticComplexityRule]
  /// based on the lint configuration.
  factory CyclomaticComplexityRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: CyclomaticComplexityParameters.fromJson,
      problemMessage: (value) =>
          'The maximum allowed complexity of a function is '
          '${value.maxCyclomaticComplexity.maxComplexity}. Please decrease it.',
    );

    return CyclomaticComplexityRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBlockFunctionBody((node) {
      if (config.parameters.ignoredEntities.isIgnoredMethod(node) ||
          config.parameters.ignoredEntities.isIgnoredClass(node)) {
        return;
      }

      final visitor = CyclomaticComplexityFlowVisitor();
      node.visitChildren(visitor);

      if (visitor.complexityEntities.length + 1 >
          config.parameters.maxCyclomaticComplexity.maxComplexity) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
