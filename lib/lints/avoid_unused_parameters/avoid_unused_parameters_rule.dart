import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_unused_parameters/avoid_unused_parameters_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// Warns about unused function, method, constructor or factory parameters.
///
/// ### Example:
/// #### BAD:
/// ```dart
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
/// #### OK:
/// ```dart
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
class AvoidUnusedParametersRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
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
    context.registry.addCompilationUnit((node) {
      final visitor = AvoidUnusedParametersVisitor();
      node.accept(visitor);

      for (final element in visitor.unusedParameters) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
