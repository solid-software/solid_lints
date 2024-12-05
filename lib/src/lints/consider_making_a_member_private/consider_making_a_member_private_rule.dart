import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/consider_making_a_member_private/visitor/consider_making_a_member_private_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns about public method, field if its not used outside.
///
/// ### Example:
/// #### BAD:
/// class X {
/// only used internally
///  void x() {
///    ...
///  }
///}
/// #### Good:
/// class X {
/// only used internally
///  void _x() {
///    ...
///  }
///}
/// #### Good:
/// class X {
///
///  void x() {
///    ...
///  }
///}
///
/// class Y {
///
/// final x = X();
///
/// void y(){
/// x.x();
/// }
/// }
class ConsiderMakingAMemberPrivateRule extends SolidLintRule {
  /// This lint rule represents
  /// the error whether we use public method, field if its not used outside.
  static const String lintName = 'consider_making_a_member_private';

  ConsiderMakingAMemberPrivateRule._(super.config);

  /// Creates a new instance of [ConsiderMakingAMemberPrivateRule]
  /// based on the lint configuration.
  factory ConsiderMakingAMemberPrivateRule.createRule(
    CustomLintConfigs configs,
  ) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => 'Consider making a member privat',
    );

    return ConsiderMakingAMemberPrivateRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = ConsiderMakingAMemberPrivateVisitor(node);
      node.visitChildren(visitor);

      final unusedMembers = visitor.unusedPublicMembers;
      final unusedGlobalVariables = visitor.unusedGlobalVariables;
      final unusedGlobalFunctions = visitor.unusedGlobalFunctions;

      for (final member in unusedMembers) {
        reporter.atNode(member, code);
      }
      for (final variable in unusedGlobalVariables) {
        reporter.atNode(variable, code);
      }
      for (final function in unusedGlobalFunctions) {
        reporter.atNode(function, code);
      }
    });
  }
}
