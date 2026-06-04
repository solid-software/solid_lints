import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_setstate/visitors/avoid_unnecessary_set_state_visitor.dart';

/// A rule which warns when setState is called inside initState, didUpdateWidget
/// or build methods and when it's called from a sync method that is called
/// inside those methods.
///
/// Cases where setState is unnecessary:
/// - synchronous calls inside State lifecycle methods:
///   - initState
///   - didUpdateWidget
///   - didChangeDependencies
/// - synchronous calls inside `build` method
///
/// Nested synchronous setState invocations are also disallowed.
///
/// Calling setState in the aforementioned methods is allowed for:
/// - async methods
/// - callbacks
///
/// ### Example:
/// #### BAD:
/// ```dart
/// void initState() {
///   setState(() => foo = 'bar');  // lint
///   changeState();                // lint
/// }
///
/// void changeState() {
///   setState(() => foo = 'bar');
/// }
///
/// void triggerFetch() async {
///   await fetch();
///   if (mounted) setState(() => foo = 'bar');
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// void initState() {
///   triggerFetch();               // OK
///   stream.listen((event) => setState(() => foo = event)); // OK
/// }
///
/// void changeState() {
///   setState(() => foo = 'bar');
/// }
///
/// void triggerFetch() async {
///   await fetch();
///   if (mounted) setState(() => foo = 'bar');
/// }
/// ```
class AvoidUnnecessarySetStateRule extends AnalysisRule {
  /// The name of the lint rule.
  static const _lintName = 'avoid_unnecessary_setstate';

  /// The message shown when the lint rule is triggered.
  static const _lintMessage = 'Avoid calling unnecessary setState. '
      'Consider changing the state directly.';

  /// The lint code for this rule.
  static const _code = LintCode(
    _lintName,
    _lintMessage,
  );

  /// Creates a new instance of [AvoidUnnecessarySetStateRule].
  AvoidUnnecessarySetStateRule()
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
    final visitor = AvoidUnnecessarySetStateVisitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}
