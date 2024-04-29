import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/number_of_parameters/models/number_of_parameters_parameters.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A number of parameters metric which checks whether we didn't exceed
/// the maximum allowed number of parameters for a function, method or
/// constructor.
///
/// ### Example:
///
/// Assuming config:
///
/// ```yaml
/// custom_lint:
///   rules:
///     - number_of_parameters:
///       max_parameters: 2
/// ```
///
/// #### BAD:
/// ```dart
/// void fn(a, b, c) {} // LINT
/// class C {
///   void method(a, b, c) {} // LINT
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// void fn(a, b) {} // OK
/// class C {
///   void method(a, b) {} // OK
/// }
/// ```
class NumberOfParametersRule
    extends SolidLintRule<NumberOfParametersParameters> {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'number_of_parameters';

  NumberOfParametersRule._(super.rule);

  /// Creates a new instance of [NumberOfParametersRule]
  /// based on the lint configuration.
  factory NumberOfParametersRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: NumberOfParametersParameters.fromJson,
      problemMessage: (value) =>
          'The maximum allowed number of parameters is ${value.maxParameters}. '
          'Try reducing the number of parameters.',
    );

    return NumberOfParametersRule._(rule);
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
