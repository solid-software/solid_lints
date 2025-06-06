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
    void checkTypeParameters(TypeParameterList? typeParameters) {
      _checkAndReport(typeParameters, reporter);
    }

    context.registry
      ..addClassDeclaration((node) => checkTypeParameters(node.typeParameters))
      ..addFunctionDeclaration(
        (node) => checkTypeParameters(node.functionExpression.typeParameters),
      )
      ..addMethodDeclaration((node) => checkTypeParameters(node.typeParameters))
      ..addGenericTypeAlias((node) => checkTypeParameters(node.typeParameters))
      ..addExtensionDeclaration(
        (node) => checkTypeParameters(node.typeParameters),
      )
      ..addMixinDeclaration((node) => checkTypeParameters(node.typeParameters));
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
