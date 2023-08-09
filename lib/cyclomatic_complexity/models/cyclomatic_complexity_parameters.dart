/// A data model class that represents the cyclomatic complexity input
/// paramters.
class CyclomaticComplexityParameters {
  /// Min value of complexity level
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
