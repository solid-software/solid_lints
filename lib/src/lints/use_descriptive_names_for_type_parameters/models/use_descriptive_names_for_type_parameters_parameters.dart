/// A data model class that represents the
/// "use descriptive names for type parameters" input parameters.
class UseDescriptiveNamesForTypeParametersParameters {
  static const _defaultMinTypeParameters = 3;

  /// Minimum number of type parameters required before the rule is enforced.
  final int minTypeParameters;

  /// Constructor for [UseDescriptiveNamesForTypeParametersParameters] model
  const UseDescriptiveNamesForTypeParametersParameters({
    required this.minTypeParameters,
  });

  /// Method for creating from json data
  factory UseDescriptiveNamesForTypeParametersParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      UseDescriptiveNamesForTypeParametersParameters(
        minTypeParameters:
            json['min_type_parameters'] as int? ?? _defaultMinTypeParameters,
      );
}
