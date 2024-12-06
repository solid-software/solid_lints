import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_unused_parameters/models/avoid_unused_parameters.dart';
import 'package:solid_lints/src/lints/avoid_unused_parameters/visitors/avoid_unused_parameters_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns about unused function, method, constructor or factory parameters.
///
/// ### Example:
/// #### BAD:
/// ```dart
/// typedef MaxFun = int Function(int a, int b);
/// final MaxFun bad = (int a, int b) => 1; // LINT
/// final MaxFun testFun = (int a, int b) { // LINT
///   return 4;
/// };
/// final optional = (int a, [int b = 0]) { // LINT
///   return a;
/// };
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
///   static void staticMethod(int _) {} // OK
///   void method(String _) {} // OK
///
///   TestClass([int _]); // OK
///   factory TestClass.named(int _) { // OK
///     return TestClass();
///   }
/// }
/// ```
///
/// #### Allowed:
/// ```dart
/// typedef Named = String Function({required String text});
/// final Named named = ({required text}) {
///  return '';
/// };
///
/// ```
class AvoidUnusedParametersRule extends SolidLintRule<AvoidUnusedParameters> {
  /// This lint rule represents
  /// the error whether we use bad formatted double literals.
  static const String lintName = 'avoid_unused_parameters';

  AvoidUnusedParametersRule._(super.config);

  /// Creates a new instance of [AvoidUnusedParametersRule]
  /// based on the lint configuration.
  factory AvoidUnusedParametersRule.createRule(
    CustomLintConfigs configs,
  ) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidUnusedParameters.fromJson,
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
    context.registry.addDeclaration((node) {
      final isIgnored = config.parameters.exclude.shouldIgnore(node);

      if (isIgnored) return;

      final visitor = AvoidUnusedParametersVisitor();
      node.accept(visitor);

      for (final element in visitor.unusedParameters) {
        reporter.atNode(element, code);
      }
    });
  }
}
