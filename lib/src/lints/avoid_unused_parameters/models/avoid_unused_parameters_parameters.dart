import 'package:solid_lints/src/common/parameters/excluded_annotations_list_parameter.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// A data model class that represents the `avoid_unused_parameters` input
/// parameters.
class AvoidUnusedParametersParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// A list of annotations that should be ignored during class check.
  final ExcludedAnnotationsListParameter excludeAnnotation;

  /// Constructor for [AvoidUnusedParametersParameters] model.
  AvoidUnusedParametersParameters({
    required this.exclude,
    required this.excludeAnnotation,
  });

  /// Empty [AvoidUnusedParametersParameters] model, excludes nothing.
  factory AvoidUnusedParametersParameters.empty() {
    return AvoidUnusedParametersParameters(
      exclude: ExcludedIdentifiersListParameter(exclude: []),
      excludeAnnotation: ExcludedAnnotationsListParameter(
        excludedAnnotations: {},
      ),
    );
  }

  /// Method for creating from json data.
  factory AvoidUnusedParametersParameters.fromJson(Map<String, dynamic> json) {
    return AvoidUnusedParametersParameters(
      exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      excludeAnnotation: ExcludedAnnotationsListParameter.fromJson(json),
    );
  }
}
