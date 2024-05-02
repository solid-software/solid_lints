/// Cyclomatic complexity metric limits configuration.
class MaxCyclomaticComplexityParameters {
  /// Threshold cyclomatic complexity level, exceeding it triggers a warning.
  final int maxComplexity;

  /// Reference: NIST 500-235 item 2.5
  static const _defaultMaxComplexity = 10;

  /// Constructor for [MaxCyclomaticComplexityParameters] model
  const MaxCyclomaticComplexityParameters({
    required this.maxComplexity,
  });

  /// Method for creating from json data
  factory MaxCyclomaticComplexityParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      MaxCyclomaticComplexityParameters(
        maxComplexity: json['max_complexity'] as int? ?? _defaultMaxComplexity,
      );
}
