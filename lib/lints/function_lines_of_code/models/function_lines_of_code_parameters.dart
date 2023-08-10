/// A data model class that represents the "source lines of code" input
/// parameters.
class FunctionLinesOfCodeParameters {
  /// Maximum number of lines
  final int maxLines;

  static const _defaultMaxLines = 200;

  /// Constructor for [FunctionLinesOfCodeParameters] model
  const FunctionLinesOfCodeParameters({
    required this.maxLines,
  });

  /// Method for creating from json data
  factory FunctionLinesOfCodeParameters.fromJson(Map<String, Object?> json) =>
      FunctionLinesOfCodeParameters(
        maxLines: json['max_lines'] as int? ?? _defaultMaxLines,
      );
}