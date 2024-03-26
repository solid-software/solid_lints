/// Cyclomatic complexity metric limits configuration.
class CyclomaticComplexityParameters {
  /// Threshold cyclomatic complexity level, exceeding it triggers a warning.
  final int maxComplexity;

  /// Reference: NIST 500-235 item 2.5
  static const _defaultMaxComplexity = 10;

  /// Constructor for [CyclomaticComplexityParameters] model
  const CyclomaticComplexityParameters({
    required this.maxComplexity,
  });

  /// Method for creating from json data
  factory CyclomaticComplexityParameters.fromJson(Map<String, Object?> json) =>
      CyclomaticComplexityParameters(
        maxComplexity: json['max_complexity'] as int? ?? _defaultMaxComplexity,
      );
}
