/// Data model that represents the limit for the amount of lines within a
/// function.
class MaxLinesParameters {
  /// Maximum allowed number of lines of code (LoC) per function,
  /// exceeding this limit triggers a warning.
  final int maxLines;

  static const _defaultMaxLines = 200;

  ///
  const MaxLinesParameters({
    required this.maxLines,
  });

  /// Method for creating from json data
  factory MaxLinesParameters.fromJson(Map<String, Object?> json) =>
      MaxLinesParameters(
        maxLines: json['max_lines'] as int? ?? _defaultMaxLines,
      );
}
