import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/avoid_debug_print_in_release_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/avoid_final_with_getter_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/fixes/avoid_final_with_getter_fix.dart';
import 'package:solid_lints/src/lints/avoid_global_state/avoid_global_state_rule.dart';
import 'package:solid_lints/src/lints/avoid_non_null_assertion/avoid_non_null_assertion_rule.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/avoid_returning_widgets_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/avoid_unnecessary_type_assertions_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/fixes/avoid_unnecessary_type_assertions_fix.dart';
import 'package:solid_lints/src/lints/avoid_unused_parameters/avoid_unused_parameters_rule.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/cyclomatic_complexity_rule.dart';
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_rule.dart';
import 'package:solid_lints/src/lints/double_literal_format/fixes/double_literal_format_fix.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/function_lines_of_code_rule.dart';
import 'package:solid_lints/src/lints/member_ordering/member_ordering_rule.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/fixes/named_parameters_ordering_fix.dart';
import 'package:solid_lints/src/lints/named_parameters_ordering/named_parameters_ordering_rule.dart';
import 'package:solid_lints/src/lints/no_empty_block/no_empty_block_rule.dart';
import 'package:solid_lints/src/lints/no_magic_number/no_magic_number_rule.dart';
import 'package:solid_lints/src/lints/number_of_parameters/number_of_parameters_rule.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/fixes/prefer_conditional_expressions_fix.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/prefer_conditional_expressions_rule.dart';
import 'package:solid_lints/src/lints/prefer_first/fixes/prefer_first_fix.dart';
import 'package:solid_lints/src/lints/prefer_first/prefer_first_rule.dart';
import 'package:solid_lints/src/lints/prefer_last/fixes/prefer_last_fix.dart';
import 'package:solid_lints/src/lints/prefer_last/prefer_last_rule.dart';
import 'package:solid_lints/src/lints/proper_super_calls/proper_super_calls_rule.dart';
import 'package:solid_lints/src/lints/use_nearest_context/fixes/rename_nearest_context_parameter_fix.dart';
import 'package:solid_lints/src/lints/use_nearest_context/use_nearest_context_rule.dart';

/// The entry point for the Solid Lints analyser server plugin.
///
/// This plugin integrates custom lint rules into the Dart analysis server,
/// allowing them to run during static analysis.
final plugin = SolidLintsPlugin();

/// An analysis server plugin that provides Solid lint rules.
///
/// This plugin registers custom lint rules and enables them to be executed
/// by the Dart analyzer during code analysis.
class SolidLintsPlugin extends Plugin {
  @override
  String get name => 'solid_lints';

  @override
  void register(PluginRegistry registry) {
    final analysisLoader = AnalysisOptionsLoader();

    final avoidUnnecessaryTypeAssertionsRule =
        AvoidUnnecessaryTypeAssertionsRule();
    final doubleLiteralFormatRule = DoubleLiteralFormatRule();
    final preferFirstRule = PreferFirstRule();
    final preferConditionalExpressionsRule = PreferConditionalExpressionsRule(
      analysisOptionsLoader: analysisLoader,
    );
    final preferLastRule = PreferLastRule();

    final lintRules = [
      AvoidFinalWithGetterRule(),
      AvoidGlobalStateRule(),
      AvoidNonNullAssertionRule(),
      avoidUnnecessaryTypeAssertionsRule,
      AvoidDebugPrintInReleaseRule(),
      doubleLiteralFormatRule,
      ProperSuperCallsRule(),
      NamedParametersOrderingRule(analysisOptionsLoader: analysisLoader),
      AvoidReturningWidgetsRule(analysisOptionsLoader: analysisLoader),
      MemberOrderingRule(analysisOptionsLoader: analysisLoader),
      AvoidUnusedParametersRule(analysisOptionsLoader: analysisLoader),
      NumberOfParametersRule(analysisOptionsLoader: analysisLoader),
      FunctionLinesOfCodeRule(analysisOptionsLoader: analysisLoader),
      CyclomaticComplexityRule(analysisOptionsLoader: analysisLoader),
      NoEmptyBlockRule(analysisOptionsLoader: analysisLoader),
      UseNearestContextRule(),
      NoMagicNumberRule(analysisOptionsLoader: analysisLoader),
      preferFirstRule,
      preferConditionalExpressionsRule,
      preferLastRule,
      // TODO: Add more lint rules and use analysisLoader
      // for rules that need parameters
      // For example: `CyclomaticComplexityRule(analysisLoader)`
    ];

    for (final lintRule in lintRules) {
      registry.registerLintRule(lintRule);
    }

    for (final code in doubleLiteralFormatRule.diagnosticCodes) {
      registry.registerFixForRule(code, DoubleLiteralFormatFix.new);
    }

    registry.registerFixForRule(
      AvoidFinalWithGetterRule.code,
      AvoidFinalWithGetterFix.new,
    );

    registry.registerFixForRule(
      avoidUnnecessaryTypeAssertionsRule.diagnosticCode,
      AvoidUnnecessaryTypeAssertionsFix.new,
    );

    registry.registerFixForRule(
      UseNearestContextRule.code,
      RenameNearestContextParameterFix.new,
    );

    registry.registerFixForRule(
      preferFirstRule.diagnosticCode,
      PreferFirstFix.new,
    );

    registry.registerFixForRule(
      preferLastRule.diagnosticCode,
      PreferLastFix.new,
    );

    registry.registerFixForRule(
      preferConditionalExpressionsRule.diagnosticCode,
      PreferConditionalExpressionsFix.new,
    );

    registry.registerFixForRule(
      NamedParametersOrderingRule.code,
      NamedParametersOrderingFix.new,
    );
  }
}
