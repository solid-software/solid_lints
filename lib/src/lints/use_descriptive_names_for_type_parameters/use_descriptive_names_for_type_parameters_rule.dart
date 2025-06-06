import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `use_descriptive_names_for_type_parameters` rule which
/// warns about single-letter type parameter names when there are
/// three or more type parameters.
class UseDescriptiveNamesForTypeParametersRule extends SolidLintRule {
  /// The lint rule name.
  static const lintName = 'use_descriptive_names_for_type_parameters';

  UseDescriptiveNamesForTypeParametersRule._(super.config);

  /// Creates a new instance of [UseDescriptiveNamesForTypeParametersRule]
  /// based on the lint configuration.
  factory UseDescriptiveNamesForTypeParametersRule.createRule(
    CustomLintConfigs configs,
  ) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) =>
          'Type parameters should have descriptive names instead '
          'of single letters when there are three or more type parameters.',
    );

    return UseDescriptiveNamesForTypeParametersRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      _checkAndReport(node.typeParameters, reporter);
    });

    context.registry.addFunctionDeclaration((node) {
      _checkAndReport(node.functionExpression.typeParameters, reporter);
    });

    context.registry.addMethodDeclaration((node) {
      _checkAndReport(node.typeParameters, reporter);
    });

    context.registry.addGenericTypeAlias((node) {
      _checkAndReport(node.typeParameters, reporter);
    });

    context.registry.addExtensionDeclaration((node) {
      _checkAndReport(node.typeParameters, reporter);
    });

    context.registry.addMixinDeclaration((node) {
      _checkAndReport(node.typeParameters, reporter);
    });
  }

  void _checkAndReport(
    TypeParameterList? typeParameters,
    ErrorReporter reporter,
  ) {
    if (typeParameters == null || typeParameters.typeParameters.length < 3) {
      return;
    }

    for (final param in typeParameters.typeParameters) {
      final name = param.name.lexeme;
      if (name.length == 1) {
        reporter.atNode(param, code);
      }
    }
  }
}
