import 'package:solid_lints/src/lints/function_lines_of_code/models/max_lines_parameters.dart';
import 'package:solid_lints/src/models/ignored_entities_model/ignored_entities_model.dart';

/// A data model class that represents the `function_lines_of_code` config
/// parameters.
class FunctionLinesOfCodeParameters {
  /// The `max_lines` configuration
  final MaxLinesParameters maxLinesModel;

  /// The `exclude` configuration
  final IgnoredEntitiesModel ignoredEntitiesModel;

  /// Constructor for [FunctionLinesOfCodeParameters] model
  const FunctionLinesOfCodeParameters({
    required this.maxLinesModel,
    required this.ignoredEntitiesModel,
  });

  /// Method for creating from json data
  factory FunctionLinesOfCodeParameters.fromJson(Map<String, Object?> json) =>
      FunctionLinesOfCodeParameters(
        maxLinesModel: MaxLinesParameters.fromJson(json),
        ignoredEntitiesModel: IgnoredEntitiesModel.fromJson(json),
      );
}
