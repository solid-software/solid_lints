import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_unnecessary_setstate/visitor/avoid_unnecessary_set_state_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

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
/// ## Example:
/// ### BAD:
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
/// ### GOOD:
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
class AvoidUnnecessarySetStateRule extends SolidLintRule {
  /// The lint name of this lint rule that represents
  /// the error whether we use setState in inappropriate way.
  static const lintName = 'avoid_unnecessary_setstate';

  AvoidUnnecessarySetStateRule._(super.config);

  /// Creates a new instance of [AvoidUnnecessarySetStateRule]
  /// based on the lint configuration.
  factory AvoidUnnecessarySetStateRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      name: lintName,
      configs: configs,
      problemMessage: (_) => 'Avoid calling unnecessary setState. '
          'Consider changing the state directly.',
    );
    return AvoidUnnecessarySetStateRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final visitor = AvoidUnnecessarySetStateVisitor();
      visitor.visitClassDeclaration(node);
      for (final element in visitor.setStateInvocations) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
