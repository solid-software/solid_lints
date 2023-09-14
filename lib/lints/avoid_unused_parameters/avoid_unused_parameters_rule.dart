import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_unused_parameters/avoid_unused_parameters_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `avoid-unused-parameters` rule which
/// warns about unused parameters
class AvoidUnusedParametersRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const String lintName = 'avoid-unused-parameters';

  AvoidUnusedParametersRule._(super.config);

  /// Creates a new instance of [AvoidUnusedParametersRule]
  /// based on the lint configuration.
  factory AvoidUnusedParametersRule.createRule(
    CustomLintConfigs configs,
  ) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => 'Parameter is unused.',
    );

    return AvoidUnusedParametersRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      final visitor = AvoidUnusedParametersVisitor();
      visitor.visitMethodDeclaration(node);

      for (final element in visitor.unusedParameters) {
        reporter.reportErrorForNode(code, element);
      }
    });

    context.registry.addFunctionDeclaration((node) {
      final visitor = AvoidUnusedParametersVisitor();
      visitor.visitFunctionDeclaration(node);

      for (final element in visitor.unusedParameters) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}