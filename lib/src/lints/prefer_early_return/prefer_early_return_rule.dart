import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/prefer_early_return/models/prefer_early_return_parameters.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/prefer_early_return_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A rule which highlights `if` statements that span the entire body of a
/// function or loop, and suggests replacing them with a reversed boolean check
/// with an early return or continue.
///
/// ### Example config:
///
/// ```yaml
/// solid_lints:
///   diagnostics:
///     prefer_early_return:
///       maximum_statements: 1
///       ignore_if_case: true
/// ```
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// void func() {
///   if (a) { //LINT
///     c;
///     d;
///   }
/// }
///
/// void loop() {
///   for (final item in items) {
///     if (item.isValid) { //LINT
///       process(item);
///       save(item);
///     }
///   }
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// void func() {
///   if (!a) return;
///   c;
///   d;
/// }
///
/// void loop() {
///   for (final item in items) {
///     if (!item.isValid) continue;
///     process(item);
///     save(item);
///   }
/// }
/// ```
class PreferEarlyReturnRule extends SolidLintRule<PreferEarlyReturnParameters> {
  /// Lint name
  static const String lintName = 'prefer_early_return';

  /// Lint code
  static const LintCode _code = LintCode(
    lintName,
    'Use reverse if to reduce nesting',
  );

  /// Creates an instance of [PreferEarlyReturnRule]
  PreferEarlyReturnRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description: 'Use reverse if to reduce nesting',
         parametersParser: PreferEarlyReturnParameters.fromJson,
       );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ?? PreferEarlyReturnParameters.empty();

    final visitor = PreferEarlyReturnVisitor(
      rule: this,
      context: context,
      parameters: parameters,
    );

    registry
      ..addBlockFunctionBody(this, visitor)
      ..addForStatement(this, visitor)
      ..addWhileStatement(this, visitor)
      ..addDoStatement(this, visitor);
  }
}
