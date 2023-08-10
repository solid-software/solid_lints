library solid_metrics;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_global_state/avoid_global_state_rule.dart';
import 'package:solid_lints/lints/avoid_late_keyword/avoid_late_keyword_rule.dart';
import 'package:solid_lints/lints/avoid_non_null_assertion/avoid_non_null_assertion_rule.dart';
import 'package:solid_lints/lints/cyclomatic_complexity/cyclomatic_complexity_metric.dart';
import 'package:solid_lints/lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/lints/function_lines_of_code/function_lines_of_code_metric.dart';
import 'package:solid_lints/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:solid_lints/lints/number_of_parameters/models/number_of_parameters_parameters.dart';
import 'package:solid_lints/lints/number_of_parameters/number_of_parameters_metric.dart';
import 'package:solid_lints/models/metric_rule.dart';

/// creates plugin
PluginBase createPlugin() => _SolidLints();

/// Solid metric linter
class _SolidLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    final List<LintRule> rules = [];

    final cyclomaticComplexity = MetricRule<CyclomaticComplexityParameters>(
      configs: configs,
      name: CyclomaticComplexityMetric.lintName,
      factory: CyclomaticComplexityParameters.fromJson,
      problemMessage: (value) => ''
          'The maximum allowed complexity of a function is '
          '${value.maxComplexity}. Please decrease it.',
    );

    if (cyclomaticComplexity.enabled) {
      rules.add(CyclomaticComplexityMetric(cyclomaticComplexity));
    }

    final numberOfParameters = MetricRule<NumberOfParametersParameters>(
      configs: configs,
      name: NumberOfParametersMetric.lintName,
      factory: NumberOfParametersParameters.fromJson,
      problemMessage: (value) => ''
          'The maximum allowed number of parameters is ${value.maxParameters}. '
          'Try reducing the number of parameters.',
    );

    if (numberOfParameters.enabled) {
      rules.add(NumberOfParametersMetric(numberOfParameters));
    }

    final functionLinesOfCode = MetricRule<FunctionLinesOfCodeParameters>(
      configs: configs,
      name: FunctionLinesOfCodeMetric.lintName,
      factory: FunctionLinesOfCodeParameters.fromJson,
      problemMessage: (value) => ''
          'The maximum allowed number of lines is ${value.maxLines}. '
          'Try splitting this function into smaller parts.',
    );

    if (functionLinesOfCode.enabled) {
      rules.add(FunctionLinesOfCodeMetric(functionLinesOfCode));
    }

    final avoidNonNullAssertion = MetricRule(
      configs: configs,
      name: AvoidNonNullAssertionRule.lintName,
      problemMessage: (_) => ''
          'Avoid using the bang operator. '
          'It may result in runtime exceptions.',
    );

    if (avoidNonNullAssertion.enabled) {
      rules.add(
        AvoidNonNullAssertionRule(code: avoidNonNullAssertion.lintCode),
      );
    }

    final avoidLateKeyword = MetricRule(
      configs: configs,
      name: AvoidLateKeywordRule.lintName,
      problemMessage: (_) => ''
          'Avoid using the "late" keyword. '
          'It may result in runtime exceptions.',
    );

    if (avoidLateKeyword.enabled) {
      rules.add(AvoidLateKeywordRule(code: avoidLateKeyword.lintCode));
    }

    final avoidGlobalState = MetricRule(
      configs: configs,
      name: AvoidGlobalStateRule.lintName,
      problemMessage: (_) => 'Avoid variables that can be globally mutated.',
    );

    if (avoidGlobalState.enabled) {
      rules.add(AvoidGlobalStateRule(code: avoidGlobalState.lintCode));
    }

    return rules;
  }
}
