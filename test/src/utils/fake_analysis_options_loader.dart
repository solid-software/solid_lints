import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';

/// A fake implementation of [AnalysisOptionsLoader] for testing.
class FakeAnalysisOptionsLoader implements AnalysisOptionsLoader {
  /// Options for rules returned by [getRuleOptions] and
  /// [getRuleOptionsForFile].
  final Map<String, Object?> ruleOptions;

  /// Excluded files for [isFileExcludedForFile].
  final Map<String, bool> excludedFiles;

  /// Result returned by [isRuleDisabled].
  bool isRuleDisabledResult;

  /// Result returned by [isFileExcluded].
  bool isFileExcludedResult;

  /// Result returned by [isFileExcludedForFile].
  bool? isFileExcludedForFileResult;

  /// Creates a new instance of [FakeAnalysisOptionsLoader].
  FakeAnalysisOptionsLoader({
    this.ruleOptions = const {},
    this.excludedFiles = const {},
    this.isRuleDisabledResult = false,
    this.isFileExcludedResult = false,
    this.isFileExcludedForFileResult,
  });

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
  bool isRuleDisabled(RuleContext context, String ruleName) =>
      isRuleDisabledResult;

  @override
  bool isFileExcluded(RuleContext context) => isFileExcludedResult;

  @override
  bool isFileExcludedForFile(String filePath) =>
      excludedFiles[filePath] ??
      isFileExcludedForFileResult ??
      isFileExcludedResult;
}
