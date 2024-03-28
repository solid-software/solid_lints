import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/prefer_guard_clause/visitors/prefer_guard_clause_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `prefer_guard_clause` rule which promotes using guard clauses
/// over nesting `if` statements
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
class PreferGuardClauseRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if
  /// 'if' statements should be reversed
  static const String lintName = 'prefer_guard_clause';

  PreferGuardClauseRule._(super.config);

  /// Creates a new instance of [PreferGuardClauseRule]
  /// based on the lint configuration.
  factory PreferGuardClauseRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) =>
          "Prefer using guard clause over nesting `if` statements",
    );

    return PreferGuardClauseRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      if (node is! FunctionDeclaration && node is! MethodDeclaration) {
        return;
      }
      final visitor = PreferGuardClauseVisitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
