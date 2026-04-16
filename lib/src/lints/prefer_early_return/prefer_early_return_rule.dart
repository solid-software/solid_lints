import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/prefer_early_return_visitor.dart';

/// A rule which highlights `if` statements that span the entire body,
/// and suggests replacing them with a reversed boolean check
/// with an early return.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// void func() {
///   if (a) { //LINT
///     if (b) { //LINT
///       c;
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
///   if (!b) return;
///   c;
/// }
/// ```
class PreferEarlyReturnRule extends AnalysisRule {
  /// Lint name
  static const String lintName = 'prefer_early_return';

  /// Lint code
  static const LintCode _code = LintCode(
    lintName,
    "Use reverse if to reduce nesting",
  );

  /// Creates an instance of [PreferEarlyReturnRule]
  PreferEarlyReturnRule()
      : super(
          name: lintName,
          description: 'Use reverse if to reduce nesting',
        );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addBlockFunctionBody(
      this,
      PreferEarlyReturnVisitor(
        rule: this,
        context: context,
      ),
    );
  }
}
