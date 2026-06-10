import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/no_equal_then_else/visitors/no_equal_then_else_visitor.dart';

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
class NoEqualThenElseRule extends AnalysisRule {
  /// The name of the lint rule.
  static const String _lintName = 'no_equal_then_else';

  /// The message shown when the lint is triggered.
  static const String _lintMessage = 'Then and else branches are equal.';

  /// Lint code
  static const _code = LintCode(
    _lintName,
    _lintMessage,
  );

  /// Create a new instance of [NoEqualThenElseRule]
  NoEqualThenElseRule()
    : super(
        name: _lintName,
        description: _lintMessage,
      );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = NoEqualThenElseVisitor(this);
    registry.addIfStatement(this, visitor);
    registry.addConditionalExpression(this, visitor);
  }
}
