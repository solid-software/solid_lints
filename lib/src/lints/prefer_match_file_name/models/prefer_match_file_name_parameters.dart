import 'package:solid_lints/src/common/parameters/excluded_entities_list_parameter.dart';

/// A data model class that represents the "prefer match file name" input
/// parameters
class PreferMatchFileNameParameters {
  /// A list of entities that should be excluded from the lint.
  final ExcludedEntitiesListParameter excludeEntity;

  /// Constructor for [PreferMatchFileNameParameters] model
  const PreferMatchFileNameParameters({
    required this.excludeEntity,
  });

  /// Method for creating from json data
  factory PreferMatchFileNameParameters.fromJson(Map<String, Object?> json) =>
      PreferMatchFileNameParameters(
        excludeEntity: ExcludedEntitiesListParameter.fromJson(json),
      );
}
