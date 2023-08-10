import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/cyclomatic_complexity/visitor/cyclomatic_complexity_flow_visitor.dart';
import 'package:solid_lints/models/metric_rule.dart';

/// A Complexity metric checks content of block and detects more easier solution
class CyclomaticComplexityMetric extends DartLintRule {
  /// The [LintCode] of this lint rule that represents the error if complexity
  /// reaches maximum value.
  static const lintName = 'cyclomatic_complexity';

  /// Configuration for complexity metric rule.
  final MetricRule<CyclomaticComplexityParameters> config;

  /// Creates a new instance of [CyclomaticComplexityMetric].
  CyclomaticComplexityMetric(this.config) : super(code: config.lintCode);

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
