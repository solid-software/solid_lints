library solid_metrics;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/cyclomatic_complexity/cyclomatic_complexity_metric.dart';
import 'package:solid_lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';

/// creates plugin
PluginBase createPlugin() => _SolidLints();

/// Solid metric linter
class _SolidLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    final List<LintRule> rules = [];

    final cyclomaticComplexityRule =
        configs.rules[CyclomaticComplexityMetric.lintName];
    final cyclomaticComplexityEnabled =
        cyclomaticComplexityRule?.enabled ?? false;

    if (cyclomaticComplexityEnabled) {
      final complexityMetricParameters =
          CyclomaticComplexityParameters.fromJson(
        _getParamsForLintRule(
              configs,
              CyclomaticComplexityMetric.lintName,
            ) ??
            {},
      );

      final lintCode = LintCode(
        name: 'cyclomatic_complexity_metric',
        problemMessage: ''
            'Please decrease the complexity of function to '
            'a minimum value ${complexityMetricParameters.maxComplexity}',
      );

      rules.add(
        CyclomaticComplexityMetric(
          additionalParameters: complexityMetricParameters,
          code: lintCode,
        ),
      );
    }

    return rules;
  }

  /// Get params of lint rule
  Map<String, Object?>? _getParamsForLintRule(
    CustomLintConfigs configs,
    String code,
  ) {
    return configs.rules[code]?.json;
  }
}
