import 'package:solid_lints/src/models/excluded_identifiers_list_parameter.dart';

/// Cyclomatic complexity metric limits configuration.
class CyclomaticComplexityParameters {
  /// Threshold cyclomatic complexity level, exceeding it triggers a warning.
  final int maxComplexity;

  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Reference: NIST 500-235 item 2.5
  static const _defaultMaxComplexity = 10;

  /// Constructor for [CyclomaticComplexityParameters] model
  const CyclomaticComplexityParameters({
    required this.maxComplexity,
    required this.exclude,
  });

  /// Method for creating from json data
  factory CyclomaticComplexityParameters.fromJson(Map<String, Object?> json) =>
      CyclomaticComplexityParameters(
        maxComplexity: json['max_complexity'] as int? ?? _defaultMaxComplexity,
        exclude: ExcludedIdentifiersListParameter.fromJson(
          excludeList:
              json[ExcludedIdentifiersListParameter.excludeParameterName]
                      as Iterable? ??
                  [],
        ),
      );
}
