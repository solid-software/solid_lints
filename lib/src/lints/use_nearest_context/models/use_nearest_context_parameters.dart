import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "use nearest context" input
/// parameters.
class UseNearestContextParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Constructor for [UseNearestContextParameters] model
  const UseNearestContextParameters({
    required this.exclude,
  });

  /// Method for creating from json data
  factory UseNearestContextParameters.fromJson(Map<String, Object?> json) =>
      UseNearestContextParameters(
        exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      );
}
