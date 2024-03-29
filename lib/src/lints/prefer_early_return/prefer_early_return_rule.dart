import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/prefer_early_return/visitors/prefer_early_return_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

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
class PreferEarlyReturnRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if
  /// 'if' statements should be reversed
  static const String lintName = 'prefer_early_return';

  PreferEarlyReturnRule._(super.config);

  /// Creates a new instance of [PreferEarlyReturnRule]
  /// based on the lint configuration.
  factory PreferEarlyReturnRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => "Use reverse if to reduce nesting",
    );

    return PreferEarlyReturnRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addBlockFunctionBody((node) {
      final visitor = PreferEarlyReturnVisitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
