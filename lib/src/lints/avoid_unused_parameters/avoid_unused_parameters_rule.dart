import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unused_parameters/models/avoid_unused_parameters_parameters.dart';
import 'package:solid_lints/src/lints/avoid_unused_parameters/visitors/avoid_unused_parameters_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns about unused function, method, constructor, or factory parameters.
///
/// Named parameters are always allowed because they document the API surface.
/// Parameters whose names consist only of underscores are also ignored.
/// Overridden methods and methods used as tear-offs are skipped.
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       avoid_unused_parameters:
///         exclude:
///           - class_name: MyClass
///             method_name: myMethod
///         exclude_annotation:
///           - freezed
/// ```
///
/// {@template solid_lints.avoid_unused_parameters.example}
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// typedef MaxFun = int Function(int a, int b);
/// final MaxFun bad = (int a, int b) => 1; // LINT
/// final MaxFun testFun = (int a, int b) { // LINT
///   return 4;
/// };
/// final optional = (int a, [int b = 0]) { // LINT
///   return a;
/// };
///
/// void fun(String x) {} // LINT
/// void fun2(String x, String y) { // LINT
///   print(y);
/// }
///
/// class TestClass {
///   static void staticMethod(int a) {} // LINT
///   void method(String s) {} // LINT
///
///   TestClass([int a]); // LINT
///   factory TestClass.named(int a) { // LINT
///     return TestClass();
///   }
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// typedef MaxFun = int Function(int a, int b);
/// final MaxFun good = (int a, int b) => a + b;
/// final MaxFun testFun = (int a, int b) {
///   return a + b;
/// };
/// void fun(String _) {} // Replacing with underscores silences the warning
/// void fun2(String _, String y) {
///   print(y);
/// }
///
/// class TestClass {
///   static void staticMethod(int _) {}
///   void method(String _) {}
///
///   TestClass([int _]);
///   factory TestClass.named(int _) {
///     return TestClass();
///   }
/// }
/// ```
///
/// #### Allowed:
///
/// ```dart
/// typedef Named = String Function({required String text});
/// final Named named = ({required text}) {
///   return '';
/// };
/// ```
/// {@endtemplate}
class AvoidUnusedParametersRule
    extends SolidLintRule<AvoidUnusedParametersParameters> {
  /// The name of this lint rule.
  static const lintName = 'avoid_unused_parameters';

  /// Reported when a parameter is declared but never read in the body.
  ///
  /// {@macro solid_lints.avoid_unused_parameters.example}
  static const LintCode _code = LintCode(
    lintName,
    'Avoid unused parameters.',
    correctionMessage:
        'Remove the parameter or replace its name with underscores.',
  );

  @override
  LintCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidUnusedParametersRule].
  AvoidUnusedParametersRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'Warns about unused function, method, constructor, or factory '
             'parameters.',
         parametersParser: AvoidUnusedParametersParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        AvoidUnusedParametersParameters.empty();

    final visitor = AvoidUnusedParametersVisitor(this, parameters);

    registry.addCompilationUnit(this, visitor);
  }
}
