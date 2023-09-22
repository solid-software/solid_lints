import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/prefer_conditional_expressions/models/prefer_conditional_expressions_parameters.dart';
import 'package:solid_lints/lints/prefer_conditional_expressions/prefer_conditional_expressions_fix.dart';
import 'package:solid_lints/lints/prefer_conditional_expressions/prefer_conditional_expressions_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

// Inspired by TSLint (https://palantir.github.io/tslint/rules/prefer-conditional-expression/)

/// A `prefer-conditional-expressions` rule which warns about
/// simple if statements that can be replaced with conditional expressions
class PreferConditionalExpressionsRule
    extends SolidLintRule<PreferConditionalExpressionsParameters> {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'prefer-conditional-expressions';

  PreferConditionalExpressionsRule._(super.config);

  /// Creates a new instance of [PreferConditionalExpressionsRule]
  /// based on the lint configuration.
  factory PreferConditionalExpressionsRule.createRule(
    CustomLintConfigs configs,
  ) {
    final config = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: PreferConditionalExpressionsParameters.fromJson,
      problemMessage: (value) => 'Prefer conditional expression.',
    );

    return PreferConditionalExpressionsRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = PreferConditionalExpressionsVisitor(
        ignoreNested: config.parameters.ignoreNested,
      );
      node.accept(visitor);

      for (final element in visitor.statementsInfo) {
        reporter.reportErrorForNode(
          code,
          element.statement,
          null,
          null,
          element,
        );
      }
    });
  }

  @override
  List<Fix> getFixes() => [PreferConditionalExpressionsFix()];
}
