import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "avoid returning widgets" input
/// parameters.
class AvoidReturningWidgetsParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Constructor for [AvoidReturningWidgetsParameters] model
  AvoidReturningWidgetsParameters({
    required this.exclude,
  });

  /// Empty [AvoidReturningWidgetsParameters] model, excludes nothing.
  factory AvoidReturningWidgetsParameters.empty() {
    return AvoidReturningWidgetsParameters(
      exclude: ExcludedIdentifiersListParameter(exclude: []),
    );
  }

  /// Method for creating from json data
  factory AvoidReturningWidgetsParameters.fromJson(Map<String, dynamic> json) {
    return AvoidReturningWidgetsParameters(
      exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
    );
  }
}
