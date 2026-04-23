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
  /// The name of the lint
  static const String lintName = 'prefer_early_return';

  /// The message shown when the lint is triggered
  static const String lintMessage = 'Use reverse if to reduce nesting';

  /// Lint code
  static const LintCode _code = LintCode(
    lintName,
    lintMessage,
  );

  /// Creates a new instance of [PreferEarlyReturnRule]
  PreferEarlyReturnRule()
      : super(
          name: lintName,
          description: lintMessage,
        );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = PreferEarlyReturnVisitor(this);
    registry.addBlockFunctionBody(this, visitor);
  }
}
