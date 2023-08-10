/// A data model class that represents the "source lines of code" input
/// parameters.
class LinesOfCodeParameters {
  /// Maximum number of lines
  final int maxLines;

  static const _defaultMaxLines = 200;

  /// Constructor for [LinesOfCodeParameters] model
  const LinesOfCodeParameters({
    required this.maxLines,
  });

  /// Method for creating from json data
  factory LinesOfCodeParameters.fromJson(Map<String, Object?> json) =>
      LinesOfCodeParameters(
        maxLines: json['max_lines'] as int? ?? _defaultMaxLines,
      );
}
