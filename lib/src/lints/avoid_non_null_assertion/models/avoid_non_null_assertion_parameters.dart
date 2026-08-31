import 'package:solid_lints/src/common/parameters/ignored_types_list_parameter.dart';

/// A data model class that represents the "avoid non null assertion" input
/// parameters.
class AvoidNonNullAssertionParameters {
  /// Types that would be ignored by avoid-non-null-assertion rule
  ///
  /// Example:
  ///
  /// ```yaml
  /// solid_lints:
  ///   diagnostics:
  ///     avoid_non_null_assertion:
  ///       ignored_types:
  ///         - Map
  ///         - IMap
  /// ```
  ///
  /// ```dart
  /// Map<String, String> map;
  /// map['key']!; // OK
  /// ```
  final IgnoredTypesListParameter ignoredTypes;

  /// Constructor for [AvoidNonNullAssertionParameters] model
  const AvoidNonNullAssertionParameters({
    required this.ignoredTypes,
  });

  /// Empty [AvoidNonNullAssertionParameters] model, ignores nothing.
  factory AvoidNonNullAssertionParameters.empty() =>
      AvoidNonNullAssertionParameters(
        ignoredTypes: IgnoredTypesListParameter.empty(),
      );

  /// Method for creating from json data
  factory AvoidNonNullAssertionParameters.fromJson(
    Map<String, Object?> json,
  ) => AvoidNonNullAssertionParameters(
    ignoredTypes: IgnoredTypesListParameter.fromJson(json),
  );
}
