import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/proper_super_calls/visitors/proper_super_calls_visitor.dart';

/// Ensures that `super` calls are made in the correct order for the following
/// StatefulWidget methods:
///
/// - `initState`
/// - `dispose`
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// @override
/// void initState() {
///   print('');
///   super.initState(); // LINT, super.initState should be called first.
/// }
///
/// @override
/// void dispose() {
///   super.dispose(); // LINT, super.dispose should be called last.
///   print('');
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// @override
/// void initState() {
///   super.initState(); // OK
///   print('');
/// }
///
/// @override
/// void dispose() {
///   print('');
///   super.dispose(); // OK
/// }
/// ```
class ProperSuperCallsRule extends AnalysisRule {
  /// This lint rule name.
  static const String lintName = 'proper_super_calls';

  /// Error code for when super.initState() is not the first statement.
  static const _superInitStateCode = LintCode(
    lintName,
    "super.initState() should be first",
  );

  /// Error code for when super.dispose() is not the last statement.
  static const _superDisposeCode = LintCode(
    lintName,
    "super.dispose() should be last",
  );

  /// Creates a new instance of [ProperSuperCallsRule].
  ProperSuperCallsRule()
      : super(
          name: lintName,
          description:
              'Ensures that `super` calls are made in the correct order ',
        );

  @override
  LintCode get diagnosticCode => _superInitStateCode;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = ProperSuperCallsVisitor(
      onViolation: (nameToken, {required bool isInitState}) {
        // Access the reporter from the currentUnit
        final reporter = context.currentUnit?.diagnosticReporter;

        reporter?.atToken(
          nameToken,
          isInitState ? _superInitStateCode : _superDisposeCode,
        );
      },
    );

    registry.addMethodDeclaration(this, visitor);
  }
}
