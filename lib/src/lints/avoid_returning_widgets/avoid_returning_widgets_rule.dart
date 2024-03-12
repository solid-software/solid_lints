import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A rule which warns about returning widgets from functions and methods.
///
/// Using functions instead of Widget subclasses for decomposing Widget trees
/// may cause unexpected behavior and performance issues.
///
/// More details: https://github.com/flutter/flutter/issues/19269
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// Widget avoidReturningWidgets() => const SizedBox(); // LINT
///
/// class MyWidget extends StatelessWidget {
///   Widget _test1() => const SizedBox(); // LINT
///   Widget get _test3 => const SizedBox(); // LINT
/// }
/// ```
///
///
/// #### GOOD:
///
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return const SizedBox();
///   }
/// }
/// ```
class AvoidReturningWidgetsRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we return a widget.
  static const lintName = 'avoid_returning_widgets';

  AvoidReturningWidgetsRule._(super.config);

  /// Creates a new instance of [AvoidReturningWidgetsRule]
  /// based on the lint configuration.
  factory AvoidReturningWidgetsRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) =>
          'Returning a widget from a function is considered an anti-pattern. '
          'Extract your widget to a separate class.',
    );

    return AvoidReturningWidgetsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      final isWidgetReturned = switch (node) {
        FunctionDeclaration(returnType: TypeAnnotation(:final type?)) ||
        MethodDeclaration(returnType: TypeAnnotation(:final type?)) =>
          hasWidgetType(type),
        _ => false,
      };

      if (node is! MethodDeclaration && node is! FunctionDeclaration) {
        return;
      }
      print(node);
      final isOverriden = node.declaredElement?.hasOverride ?? false;

      // `build` methods return widgets by nature
      if (isWidgetReturned && !isOverriden) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
