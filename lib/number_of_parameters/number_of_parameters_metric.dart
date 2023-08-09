import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/metric_rule.dart';
import 'package:solid_lints/number_of_parameters/models/number_of_parameters_parameters.dart';

/// A number of parameters metric which checks whether we didn't exceed
/// the maximum allowed number of parameters for a function or a method
class NumberOfParametersMetric extends DartLintRule {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'number_of_parameters';

  /// Configuration for number of parameters metric rule.
  final MetricRule<NumberOfParametersParameters> config;

  /// Creates a new instance of [NumberOfParametersMetric].
  NumberOfParametersMetric(this.config) : super(code: config.lintCode);

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
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
