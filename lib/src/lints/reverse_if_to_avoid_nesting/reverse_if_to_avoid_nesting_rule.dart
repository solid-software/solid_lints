import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/reverse_if_to_avoid_nesting/visitors/reverse_if_to_avoid_nesting_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `reverse_if_to_avoid_nesting` rule which forbids
/// nesting of `if` statements if possible
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// void func() {
///   if(a){ //LINT
///     if(b){ //LINT
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
///   if(!a) return;
///   if(!b) return;
///   c;
/// }
/// ```
class ReverseIfToAvoidNestingRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if
  /// 'if' statements should be reversed
  static const String lintName = 'reverse_if_to_avoid_nesting';

  ReverseIfToAvoidNestingRule._(super.config);

  /// Creates a new instance of [ReverseIfToAvoidNestingRule]
  /// based on the lint configuration.
  factory ReverseIfToAvoidNestingRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) => "Use reverse `if` statement to avoid nesting",
    );

    return ReverseIfToAvoidNestingRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIfStatement((node) {
      final visitor = ReverseIfToAvoidNestingVisitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
