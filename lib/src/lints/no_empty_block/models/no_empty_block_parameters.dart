import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the "avoid returning widgets" input
/// parameters.
class NoEmptyBlockParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Constructor for [NoEmptyBlockParameters] model
  NoEmptyBlockParameters({
    required this.exclude,
  });

  /// Method for creating from json data
  factory NoEmptyBlockParameters.fromJson(Map<String, dynamic> json) {
    return NoEmptyBlockParameters(
      exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
    );
  }
}
