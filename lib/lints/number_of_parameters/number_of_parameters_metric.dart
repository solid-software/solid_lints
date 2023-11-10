import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/number_of_parameters/models/number_of_parameters_parameters.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A number of parameters metric which checks whether we didn't exceed
/// the maximum allowed number of parameters for a function or a method
class NumberOfParametersMetric
    extends SolidLintRule<NumberOfParametersParameters> {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'number_of_parameters';

  NumberOfParametersMetric._(super.rule);

  /// Creates a new instance of [NumberOfParametersMetric]
  /// based on the lint configuration.
  factory NumberOfParametersMetric.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: NumberOfParametersParameters.fromJson,
      problemMessage: (value) =>
          'The maximum allowed number of parameters is ${value.maxParameters}. '
          'Try reducing the number of parameters.',
    );

    return NumberOfParametersMetric._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      final parameters = switch (node) {
        (final MethodDeclaration node) =>
          node.parameters?.parameters.length ?? 0,
        (final FunctionDeclaration node) =>
          node.functionExpression.parameters?.parameters.length ?? 0,
        _ => 0,
      };

      if (parameters > config.parameters.maxParameters) {
        reporter.reportErrorForOffset(
          code,
          node.firstTokenAfterCommentAndMetadata.offset,
          node.end,
        );
      }
    });
  }
}
