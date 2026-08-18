import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/fixes/prefer_conditional_expressions_fix.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/models/prefer_conditional_expressions_parameters.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/visitors/prefer_conditional_expressions_visitor.dart';
import 'package:solid_lints/src/models/rule_with_fixes.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

// Inspired by TSLint (https://palantir.github.io/tslint/rules/prefer-conditional-expression/)

/// Highlights simple "if" statements that can be replaced with conditional
/// expressions
///
/// ### Example config:
///
/// ```yaml
/// solid_lints:
///   diagnostics:
///     prefer_conditional_expressions:
///       ignore_nested: true
/// ```
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// // LINT
/// if (x > 0) {
///   x = 1;
/// } else {
///   x = 2;
/// }
///
/// // LINT
/// if (x > 0) x = 1;
/// else x = 2;
///
/// int fn() {
///   // LINT
///   if (x > 0) {
///     return 1;
///   } else {
///     return 2;
///   }
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// x = x > 0 ? 1 : 2;
///
/// int fn() {
///   return x > 0 ? 1 : 2;
/// }
/// ```
class PreferConditionalExpressionsRule
    extends SolidLintRule<PreferConditionalExpressionsParameters>
    implements RuleWithFixes {
  /// This lint rule represents the error when an if-else statement
  /// can be simplified to a conditional expression.
  static const lintName = 'prefer_conditional_expressions';

  static const _code = LintCode(
    lintName,
    'Prefer conditional expression.',
  );

  /// Creates a new instance of [PreferConditionalExpressionsRule]
  PreferConditionalExpressionsRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: _code.lowerCaseName,
         description: _code.problemMessage,
         parametersParser: PreferConditionalExpressionsParameters.fromJson,
       );

  @override
  LintCode get diagnosticCode => _code;

  @override
  FixesForCodes get fixesForCodes => const [
    MapEntry(_code, PreferConditionalExpressionsFix.new),
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        PreferConditionalExpressionsParameters.empty();

    final visitor = PreferConditionalExpressionsVisitor(
      rule: this,
      ignoreNested: parameters.ignoreNested,
    );

    registry.addCompilationUnit(this, visitor);
  }
}
