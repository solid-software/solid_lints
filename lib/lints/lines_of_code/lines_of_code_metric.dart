import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/lines_of_code/models/lines_of_code_parameters.dart';
import 'package:solid_lints/models/metric_rule.dart';
import 'package:solid_lints/visitors/source_code_visitor.dart';

/// A number of lines metric which checks whether we didn't exceed
/// the maximum allowed number of lines for a file
class LinesOfCodeMetric extends DartLintRule {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'lines_of_code';

  /// Configuration for number of parameters metric rule.
  final MetricRule<LinesOfCodeParameters> config;

  /// Creates a new instance of [LinesOfCodeMetric].
  LinesOfCodeMetric(this.config) : super(code: config.lintCode);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final visitor = SourceCodeVisitor(resolver.lineInfo);

    context.registry.addNode((node) {
      node.visitChildren(visitor);

      if (visitor.linesWithCode.length > config.parameters.maxLines) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
