/// Data class representing parsed rules configuration and disabled rules.
class RulesData {
  /// The active rules options mapped by rule name.
  final Map<String, Map<String, Object?>> rules;

  /// The set of explicitly disabled rules.
  final Set<String> disabledRules;

  /// The set of file paths or glob patterns excluded from analysis.
  final Set<String> excludedPatterns;

  /// Creates a new instance of [RulesData].
  const RulesData({
    required this.rules,
    required this.disabledRules,
    required this.excludedPatterns,
  });

  /// Creates a new empty instance of [RulesData].
  const RulesData.empty()
    : rules = const {},
      disabledRules = const {},
      excludedPatterns = const {};
}
