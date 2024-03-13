/// A data model class that represents the "function lines of code" input
/// parameters.
class FunctionLinesOfCodeParameters {
  /// Maximum allowed number of lines of code (LoC) per function,
  /// exceeding this limit triggers a warning.
  final int maxLines;
  /// Method names to be excluded from the rule check
  final List<String> excludeNames;

  static const _defaultMaxLines = 200;

  /// Constructor for [FunctionLinesOfCodeParameters] model
  const FunctionLinesOfCodeParameters({
    required this.maxLines,
    required this.excludeNames,
  });

  /// Method for creating from json data
  factory FunctionLinesOfCodeParameters.fromJson(Map<String, Object?> json) =>
      FunctionLinesOfCodeParameters(
        maxLines: json['max_lines'] as int? ?? _defaultMaxLines,
        excludeNames:
            List<String>.from(json['excludeNames'] as Iterable? ?? []),
      );
}
