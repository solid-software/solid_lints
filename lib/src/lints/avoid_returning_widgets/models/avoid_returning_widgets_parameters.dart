import 'package:solid_lints/src/models/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "avoid returning widgets" input
/// parameters.
class AvoidReturningWidgetsParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Constructor for [AvoidReturningWidgetsParameters] model
  AvoidReturningWidgetsParameters({
    required this.exclude,
  });

  /// Method for creating from json data
  factory AvoidReturningWidgetsParameters.fromJson(Map<String, dynamic> json) {
    return AvoidReturningWidgetsParameters(
      exclude: ExcludedIdentifiersListParameter.fromJson(
        excludeList: json[ExcludedIdentifiersListParameter.excludeParameterName]
                as Iterable? ??
            [],
      ),
    );
  }
}
