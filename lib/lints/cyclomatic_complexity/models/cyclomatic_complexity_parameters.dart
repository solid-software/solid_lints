/// Cyclomatic complexity metric limits configuration.
class CyclomaticComplexityParameters {
  /// Threshold cyclomatic complexity level, exceeding it triggers a warning.
  final int maxComplexity;

  static const _defaultMaxComplexity = 2;

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
