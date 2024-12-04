import 'package:solid_lints/src/models/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "avoid returning widgets" input
/// parameters.
class AvoidUnusedParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Constructor for [AvoidUnusedParameters] model
  AvoidUnusedParameters({
    required this.exclude,
  });

  /// Method for creating from json data
  factory AvoidUnusedParameters.fromJson(Map<String, dynamic> json) {
    return AvoidUnusedParameters(
      exclude: ExcludedIdentifiersListParameter.fromJson(
        excludeList:
            json[ExcludedIdentifiersListParameter.excludeParameterName] as Iterable? ?? [],
      ),
    );
  }
}
