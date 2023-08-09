import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/cyclomatic_complexity/visitor/cyclomatic_complexity_flow_visitor.dart';

/// A Complexity metric checks content of block and detects more easier solution
class CyclomaticComplexityMetric extends DartLintRule {
  /// The [LintCode] of this lint rule that represents the error if complexity
  /// reaches maximum value.
  static const lintName = 'cyclomatic_complexity_metric';

  /// The additional parameters for this metric.
  final CyclomaticComplexityParameters additionalParameters;

  /// Creates a new instance of [CyclomaticComplexityMetric].
  const CyclomaticComplexityMetric({
    required this.additionalParameters,
    required super.code,
  });

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
          additionalParameters.maxComplexity) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
