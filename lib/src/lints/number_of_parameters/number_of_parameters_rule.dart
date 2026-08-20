import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/number_of_parameters/models/number_of_parameters_parameters.dart';
import 'package:solid_lints/src/lints/number_of_parameters/visitors/number_of_parameters_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A number of parameters metric which checks whether we didn't exceed
/// the maximum allowed number of parameters for a function or method.
///
/// ### Example:
///
/// Assuming config:
///
/// ```yaml
/// solid_lints:
///   diagnostics:
///     number_of_parameters:
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
  /// The name of this lint rule.
  static const lintName = 'number_of_parameters';

  static const _code = LintCode(
    lintName,
    'The maximum allowed number of parameters is {0}. '
    'Try reducing the number of parameters.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [NumberOfParametersRule].
  NumberOfParametersRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             "Checks whether we didn't exceed the maximum allowed number "
             'of parameters for a function or method.',
         parametersParser: NumberOfParametersParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        NumberOfParametersParameters.empty();

    final visitor = NumberOfParametersVisitor(this, parameters);

    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}
