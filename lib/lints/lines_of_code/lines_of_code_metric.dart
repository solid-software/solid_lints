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
    var exceedsLines = false;

    context.registry.addNode((node) {
      // Allows us to skip analyzing the file when we already determined that
      // it's either too long or when the node is not matching the entire file
      if (exceedsLines || node.offset != 0) {
        return;
      }

      node.visitChildren(visitor);
      if (visitor.linesWithCode.length > config.parameters.maxLines) {
        exceedsLines = true;

        // Start on the second line to give us an option to declare
        // `ignore` or `expect_lint` on the first one
        reporter.reportErrorForOffset(
          code,
          resolver.lineInfo.lineStarts[1],
          node.end,
        );
      }
    });
  }
}
