import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';
import 'package:solid_lints/utils/types_utils.dart';

/// A rule which forbids returning widgets from functions and methods.
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

      // `build` methods return widgets by nature
      if (isWidgetReturned && node.declaredElement?.name != "build") {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
