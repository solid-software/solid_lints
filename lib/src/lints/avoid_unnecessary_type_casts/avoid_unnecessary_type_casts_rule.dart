import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_casts/avoid_unnecessary_type_casts_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

part 'avoid_unnecessary_type_casts_fix.dart';

/// An `avoid_unnecessary_type_casts` rule which
/// warns about unnecessary usage of `as` operator
class AvoidUnnecessaryTypeCastsRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid_unnecessary_type_casts';

  AvoidUnnecessaryTypeCastsRule._(super.config);

  /// Creates a new instance of [AvoidUnnecessaryTypeCastsRule]
  /// based on the lint configuration.
  factory AvoidUnnecessaryTypeCastsRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => "Avoid unnecessary usage of as operator.",
    );

    return AvoidUnnecessaryTypeCastsRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addAsExpression((node) {
      final visitor = AvoidUnnecessaryTypeCastsVisitor();
      visitor.visitAsExpression(node);

      for (final element in visitor.expressions.entries) {
        reporter.reportErrorForNode(code, element.key);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_UnnecessaryTypeCastsFix()];
}
