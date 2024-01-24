/// A data model class that represents the "number of parameters" input
/// parameters.
class NumberOfParametersParameters {
  /// Maximum number of parameters allowed before a warning is triggered.
  final int maxParameters;

  static const _defaultMaxParameters = 2;

  /// Constructor for [NumberOfParametersParameters] model
  const NumberOfParametersParameters({
    required this.maxParameters,
  });

  /// Method for creating from json data
  factory NumberOfParametersParameters.fromJson(Map<String, Object?> json) =>
      NumberOfParametersParameters(
        maxParameters: json['max_parameters'] as int? ?? _defaultMaxParameters,
      );
}
