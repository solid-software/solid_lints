library solid_metrics;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_debug_print/avoid_debug_print_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/avoid_final_with_getter_rule.dart';
import 'package:solid_lints/src/lints/avoid_global_state/avoid_global_state_rule.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/avoid_late_keyword_rule.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/avoid_non_null_assertion_rule.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/avoid_returning_widgets_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_setstate/avoid_unnecessary_set_state_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/avoid_unnecessary_type_assertions_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_casts/avoid_unnecessary_type_casts_rule.dart';
import 'package:solid_lints/src/lints/avoid_unrelated_type_assertions/avoid_unrelated_type_assertions_rule.dart';
import 'package:solid_lints/src/lints/avoid_unused_parameters/avoid_unused_parameters_rule.dart';
import 'package:solid_lints/src/lints/avoid_using_api/avoid_using_api_rule.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/cyclomatic_complexity_metric.dart';
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_rule.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/function_lines_of_code_metric.dart';
import 'package:solid_lints/src/lints/member_ordering/member_ordering_rule.dart';
import 'package:solid_lints/src/lints/newline_before_return/newline_before_return_rule.dart';
import 'package:solid_lints/src/lints/no_empty_block/no_empty_block_rule.dart';
import 'package:solid_lints/src/lints/no_equal_then_else/no_equal_then_else_rule.dart';
import 'package:solid_lints/src/lints/no_magic_number/no_magic_number_rule.dart';
import 'package:solid_lints/src/lints/number_of_parameters/number_of_parameters_metric.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/prefer_conditional_expressions_rule.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';
import 'package:solid_lints/src/lints/prefer_first/prefer_first_rule.dart';
import 'package:solid_lints/src/lints/prefer_last/prefer_last_rule.dart';
import 'package:solid_lints/src/lints/prefer_match_file_name/prefer_match_file_name_rule.dart';
import 'package:solid_lints/src/lints/proper_super_calls/proper_super_calls_rule.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Creates a plugin for our custom linter
PluginBase createPlugin() => _SolidLints();

/// Initialize custom solid lints
class _SolidLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    final List<SolidLintRule> supportedRules = [
      CyclomaticComplexityMetric.createRule(configs),
      NumberOfParametersMetric.createRule(configs),
      FunctionLinesOfCodeMetric.createRule(configs),
      AvoidNonNullAssertionRule.createRule(configs),
      AvoidLateKeywordRule.createRule(configs),
      AvoidGlobalStateRule.createRule(configs),
      AvoidReturningWidgetsRule.createRule(configs),
      DoubleLiteralFormatRule.createRule(configs),
      AvoidUnnecessaryTypeAssertions.createRule(configs),
      AvoidUnnecessarySetStateRule.createRule(configs),
      AvoidUnnecessaryTypeCastsRule.createRule(configs),
      AvoidUnrelatedTypeAssertionsRule.createRule(configs),
      AvoidUnusedParametersRule.createRule(configs),
      AvoidUsingApiRule.createRule(configs),
      NewlineBeforeReturnRule.createRule(configs),
      NoEmptyBlockRule.createRule(configs),
      NoEqualThenElseRule.createRule(configs),
      MemberOrderingRule.createRule(configs),
      NoMagicNumberRule.createRule(configs),
      PreferConditionalExpressionsRule.createRule(configs),
      PreferFirstRule.createRule(configs),
      PreferLastRule.createRule(configs),
      PreferMatchFileNameRule.createRule(configs),
      ProperSuperCallsRule.createRule(configs),
      AvoidDebugPrint.createRule(configs),
      PreferEarlyReturnRule.createRule(configs),
      AvoidFinalWithGetterRule.createRule(configs),
    ];

    // Return only enabled rules
    return supportedRules.where((r) => r.enabled).toList();
  }
}
