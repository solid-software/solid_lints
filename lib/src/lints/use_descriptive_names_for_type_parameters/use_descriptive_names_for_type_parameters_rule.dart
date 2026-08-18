import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/models/use_descriptive_names_for_type_parameters_parameters.dart';
import 'package:solid_lints/src/lints/use_descriptive_names_for_type_parameters/visitors/use_descriptive_names_for_type_parameters_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `use_descriptive_names_for_type_parameters` rule which
/// warns about single-letter type parameter names when there are
/// three or more type parameters.
///
/// ### Example:
///
/// Assuming config:
///
/// ```yaml
/// solid_lints:
///   diagnostics:
///     use_descriptive_names_for_type_parameters:
///       min_type_parameters: 3
/// ```
///
/// #### BAD:
/// ```dart
/// class MyClass<T, U, V> {} // LINT
/// ```
///
/// #### GOOD:
/// ```dart
/// class MyClass<TSource, TResult, TError> {} // OK
/// class MyClass2<T, U> {} // OK
/// ```
class UseDescriptiveNamesForTypeParametersRule
    extends SolidLintRule<UseDescriptiveNamesForTypeParametersParameters> {
  /// The lint rule name.
  static const lintName = 'use_descriptive_names_for_type_parameters';

  static const _code = LintCode(
    lintName,
    'Type parameters should have descriptive names instead '
    'of single letters when there are {0} or '
    'more type parameters.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [UseDescriptiveNamesForTypeParametersRule].
  UseDescriptiveNamesForTypeParametersRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'Warns about single-letter type parameter names when there are '
             'three or more type parameters.',
         parametersParser:
             UseDescriptiveNamesForTypeParametersParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        UseDescriptiveNamesForTypeParametersParameters.empty();

    final visitor = UseDescriptiveNamesForTypeParametersVisitor(
      this,
      parameters,
    );

    registry
      ..addClassDeclaration(this, visitor)
      ..addClassTypeAlias(this, visitor)
      ..addEnumDeclaration(this, visitor)
      ..addFunctionExpression(this, visitor)
      ..addMethodDeclaration(this, visitor)
      ..addGenericTypeAlias(this, visitor)
      ..addFunctionTypeAlias(this, visitor)
      ..addGenericFunctionType(this, visitor)
      ..addExtensionDeclaration(this, visitor)
      ..addMixinDeclaration(this, visitor)
      ..addExtensionTypeDeclaration(this, visitor);
  }
}
