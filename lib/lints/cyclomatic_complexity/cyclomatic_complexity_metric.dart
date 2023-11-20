import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/lints/cyclomatic_complexity/visitor/cyclomatic_complexity_flow_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A Complexity metric checks content of block and detects more easier solution
class CyclomaticComplexityMetric
    extends SolidLintRule<CyclomaticComplexityParameters> {
  /// The [LintCode] of this lint rule that represents the error if complexity
  /// reaches maximum value.
  static const lintName = 'cyclomatic_complexity';

  CyclomaticComplexityMetric._(super.rule);

  /// Creates a new instance of [CyclomaticComplexityMetric]
  /// based on the lint configuration.
  factory CyclomaticComplexityMetric.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: CyclomaticComplexityParameters.fromJson,
      problemMessage: (value) =>
          'The maximum allowed complexity of a function is '
          '${value.maxComplexity}. Please decrease it.',
    );

    return CyclomaticComplexityMetric._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final visitor = CyclomaticComplexityFlowVisitor();

    context.registry.addBlockFunctionBody((node) {
      node.visitChildren(visitor);

      if (visitor.complexityEntities.length + 1 >
          config.parameters.maxComplexity) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
