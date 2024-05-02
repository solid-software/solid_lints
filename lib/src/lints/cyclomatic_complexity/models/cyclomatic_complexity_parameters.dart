import 'package:solid_lints/src/lints/cyclomatic_complexity/models/max_cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/src/models/ignored_entities_model/ignored_entities_model.dart';

/// Config parameters for the `cyclomatic_complexity` rule
class CyclomaticComplexityParameters {
  /// `max_complexity` configuration
  final MaxCyclomaticComplexityParameters maxCyclomaticComplexity;

  /// `exclude` configuration
  final IgnoredEntitiesModel ignoredEntities;

  /// Constructor for [CyclomaticComplexityParameters] model
  const CyclomaticComplexityParameters({
    required this.maxCyclomaticComplexity,
    required this.ignoredEntities,
  });

  ///
  factory CyclomaticComplexityParameters.fromJson(Map<String, Object?> json) {
    return CyclomaticComplexityParameters(
      ignoredEntities: IgnoredEntitiesModel.fromJson(json),
      maxCyclomaticComplexity: MaxCyclomaticComplexityParameters.fromJson(json),
    );
  }
}
