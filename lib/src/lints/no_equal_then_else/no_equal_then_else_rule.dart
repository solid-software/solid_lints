import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/no_equal_then_else/no_equal_then_else_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

// Inspired by PVS-Studio (https://www.viva64.com/en/w/v6004/)

/// Warns when "if"-"else" statements or ternary conditionals have identical
/// if and else condition handlers.
///
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// final valueA = 'a';
/// final valueB = 'b';
///
/// if (condition) { // LINT
///   selectedValue = valueA;
/// } else {
///   selectedValue = valueA;
/// }
///
/// selectedValue = condition ? valueA : valueA; // LINT
/// ```
///
/// #### GOOD:
///
/// ```dart
/// final valueA = 'a';
/// final valueB = 'b';
///
/// if (condition) {
///   selectedValue = valueA;
/// } else {
///   selectedValue = valueB;
/// }
///
/// selectedValue = condition ? valueA : valueB;
/// ```
class NoEqualThenElseRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if
  /// 'if' statements or conditional expression is redundant
  static const String lintName = 'no_equal_then_else';

  NoEqualThenElseRule._(super.config);

  /// Creates a new instance of [NoEqualThenElseRule]
  /// based on the lint configuration.
  factory NoEqualThenElseRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) => "Then and else branches are equal.",
    );

    return NoEqualThenElseRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = NoEqualThenElseVisitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
