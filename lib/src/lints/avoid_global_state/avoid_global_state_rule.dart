import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Avoid top-level and static mutable variables.
///
/// Top-level variables can be modified from anywhere,
/// which leads to hard to debug applications.
///
/// Prefer using a state management solution.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// var globalMutable = 0; // LINT
///
/// class Test {
///   static int globalMutable = 0; // LINT
/// }
/// ```
///
///
/// #### GOOD:
///
/// ```dart
/// final globalFinal = 1;
/// const globalConst = 1;
///
/// class Test {
///   static const int globalConst = 1;
///   static final int globalFinal = 1;
/// }
/// ```
class AvoidGlobalStateRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use global state.
  static const lintName = 'avoid_global_state';

  AvoidGlobalStateRule._(super.config);

  /// Creates a new instance of [AvoidGlobalStateRule]
  /// based on the lint configuration.
  factory AvoidGlobalStateRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => 'Avoid variables that can be globally mutated.',
    );

    return AvoidGlobalStateRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addTopLevelVariableDeclaration(
      (node) => node.variables.variables
          .where((variable) => variable.isPublicMutable)
          .forEach((node) => reporter.atNode(node, code)),
    );
    context.registry.addFieldDeclaration((node) {
      if (!node.isStatic) return;
      node.fields.variables
          .where((variable) => variable.isPublicMutable)
          .forEach((node) => reporter.atNode(node, code));
    });
  }
}

extension on VariableDeclaration {
  bool get isMutable => !isFinal && !isConst;

  bool get isPrivate => declaredElement?.isPrivate ?? false;

  bool get isPublicMutable => isMutable && !isPrivate;
}
