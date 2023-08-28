import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_unnecessary_setstate/visitor/avoid_unnecessary_setstate_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A rule which warns when setState is called inside initState, didUpdateWidget
/// or build methods and when it's called
/// from a sync method that is called inside those methods.
class AvoidUnnecessarySetstateRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we return a widget.
  static const lintName = 'avoid_unnecessary_setstate';

  AvoidUnnecessarySetstateRule._(super.config);

  /// Creates a new instance of [AvoidUnnecessarySetstateRule]
  /// based on the lint configuration.
  factory AvoidUnnecessarySetstateRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      name: lintName,
      configs: configs,
      problemMessage: (_) => ''
          'Avoid calling unnecessary setState. '
          'Consider changing the state directly.',
    );
    return AvoidUnnecessarySetstateRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final visitor = AvoidUnnecessarySetStateVisitor();

    context.registry.addClassDeclaration((node) {
      visitor.visitClassDeclaration(node);
      for (final element in visitor.setStateInvocations) {
        reporter.reportErrorForNode(code, element);
      }
      for (final element in visitor.classMethodsInvocations) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
