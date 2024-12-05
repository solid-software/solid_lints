import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "function lines of code" input
/// parameters.
class FunctionLinesOfCodeParameters {
  /// Maximum allowed number of lines of code (LoC) per function,
  /// exceeding this limit triggers a warning.
  final int maxLines;

  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  static const _defaultMaxLines = 200;

  /// Constructor for [FunctionLinesOfCodeParameters] model
  const FunctionLinesOfCodeParameters({
    required this.maxLines,
    required this.exclude,
  });

  /// Method for creating from json data
  factory FunctionLinesOfCodeParameters.fromJson(Map<String, Object?> json) =>
      FunctionLinesOfCodeParameters(
        maxLines: json['max_lines'] as int? ?? _defaultMaxLines,
        exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      );
}
