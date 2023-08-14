import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:solid_lints/lints/function_lines_of_code/visitor/function_lines_of_code_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A number of lines metric which checks whether we didn't exceed
/// the maximum allowed number of lines for a function.
class FunctionLinesOfCodeMetric
    extends SolidLintRule<FunctionLinesOfCodeParameters> {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'function_lines_of_code';

  FunctionLinesOfCodeMetric._(super.config);

  /// Creates a new instance of [FunctionLinesOfCodeMetric]
  /// based on the lint configuration.
  factory FunctionLinesOfCodeMetric.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: FunctionLinesOfCodeParameters.fromJson,
      problemMessage: (value) => ''
          'The maximum allowed number of lines is ${value.maxLines}. '
          'Try splitting this function into smaller parts.',
    );

    return FunctionLinesOfCodeMetric._(rule);
  }

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
