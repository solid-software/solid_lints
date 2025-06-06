import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/visitors/use_descriptive_names_for_type_parameters_visitor.dart';
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
      final visitor = UseDescriptiveNamesForTypeParametersVisitor();
      visitor.visitClassDeclaration(node);
      _reportViolations(reporter, visitor.singleLetterTypeParameters);
    });

    context.registry.addFunctionDeclaration((node) {
      final visitor = UseDescriptiveNamesForTypeParametersVisitor();
      visitor.visitFunctionDeclaration(node);
      _reportViolations(reporter, visitor.singleLetterTypeParameters);
    });

    context.registry.addMethodDeclaration((node) {
      final visitor = UseDescriptiveNamesForTypeParametersVisitor();
      visitor.visitMethodDeclaration(node);
      _reportViolations(reporter, visitor.singleLetterTypeParameters);
    });

    context.registry.addGenericTypeAlias((node) {
      final visitor = UseDescriptiveNamesForTypeParametersVisitor();
      visitor.visitGenericTypeAlias(node);
      _reportViolations(reporter, visitor.singleLetterTypeParameters);
    });

    context.registry.addExtensionDeclaration((node) {
      final visitor = UseDescriptiveNamesForTypeParametersVisitor();
      visitor.visitExtensionDeclaration(node);
      _reportViolations(reporter, visitor.singleLetterTypeParameters);
    });

    context.registry.addMixinDeclaration((node) {
      final visitor = UseDescriptiveNamesForTypeParametersVisitor();
      visitor.visitMixinDeclaration(node);
      _reportViolations(reporter, visitor.singleLetterTypeParameters);
    });
  }

  void _reportViolations(
    ErrorReporter reporter,
    List<TypeParameter> singleLetterTypeParameters,
  ) {
    for (final param in singleLetterTypeParameters) {
      reporter.atNode(param, code);
    }
  }
}
