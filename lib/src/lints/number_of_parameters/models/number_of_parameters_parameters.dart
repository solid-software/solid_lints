import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "number of parameters" input
/// parameters.
class NumberOfParametersParameters {
  /// Maximum number of parameters allowed before a warning is triggered.
  final int maxParameters;

  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  static const _defaultMaxParameters = 2;

  /// Constructor for [NumberOfParametersParameters] model
  const NumberOfParametersParameters({
    required this.maxParameters,
    required this.exclude,
  });

  /// Method for creating from json data
  factory NumberOfParametersParameters.fromJson(Map<String, Object?> json) =>
      NumberOfParametersParameters(
        maxParameters: json['max_parameters'] as int? ?? _defaultMaxParameters,
        exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      );
}
