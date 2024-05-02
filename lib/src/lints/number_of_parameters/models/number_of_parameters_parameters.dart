import 'package:solid_lints/src/models/ignored_entities_model/ignored_entities_model.dart';

/// A data model class that represents the "number of parameters" input
/// parameters.
class NumberOfParametersParameters {
  /// Maximum number of parameters allowed before a warning is triggered.
  final int maxParameters;

  /// The methods/classes that this lint should ignore.
  final IgnoredEntitiesModel ignoredEntitiesModel;

  static const _defaultMaxParameters = 2;

  /// Constructor for [NumberOfParametersParameters] model
  const NumberOfParametersParameters({
    required this.maxParameters,
    required this.ignoredEntitiesModel,
  });

  /// Method for creating from json data
  factory NumberOfParametersParameters.fromJson(Map<String, Object?> json) =>
      NumberOfParametersParameters(
        maxParameters: json['max_parameters'] as int? ?? _defaultMaxParameters,
        ignoredEntitiesModel: IgnoredEntitiesModel.fromJson(json),
      );
}
