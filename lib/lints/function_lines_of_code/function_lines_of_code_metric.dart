import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:solid_lints/lints/function_lines_of_code/visitor/function_lines_of_code_visitor.dart';
import 'package:solid_lints/models/metric_rule.dart';

/// A number of lines metric which checks whether we didn't exceed
/// the maximum allowed number of lines for a function.
class FunctionLinesOfCodeMetric extends DartLintRule {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'function_lines_of_code';

  /// Configuration for number of parameters metric rule.
  final MetricRule<FunctionLinesOfCodeParameters> config;

  /// Creates a new instance of [FunctionLinesOfCodeMetric].
  FunctionLinesOfCodeMetric(this.config) : super(code: config.lintCode);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final visitor = FunctionLinesOfCodeVisitor(resolver.lineInfo);

    context.registry.addDeclaration((node) {
      node.visitChildren(visitor);

      if (visitor.linesWithCode.length > config.parameters.maxLines) {
        reporter.reportErrorForOffset(
          code,
          node.firstTokenAfterCommentAndMetadata.offset,
          node.end,
        );
      }
    });
  }
}
