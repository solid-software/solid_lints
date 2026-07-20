import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';

class FakeAnalysisOptionsLoader implements AnalysisOptionsLoader {
  final Map<String, Object?> ruleOptions;

  FakeAnalysisOptionsLoader({required this.ruleOptions});

  @override
  Map<String, Object?>? getRuleOptions(RuleContext context, String ruleName) =>
      ruleOptions;

  @override
  Map<String, Object?>? getRuleOptionsForFile(
    String filePath,
    String ruleName,
  ) => ruleOptions;

  @override
  void loadRulesOptionsFromContext(RuleContext context) {}

  @override
  bool isRuleDisabled(RuleContext context, String ruleName) => false;
}
