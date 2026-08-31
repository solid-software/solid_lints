import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';
import 'package:solid_lints/src/common/parameters/ignored_types_list_parameter.dart';

/// A data model class that represents the "avoid returning widgets" input
/// parameters.
class AvoidReturningWidgetsParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Types that would be ignored by avoid-returning-widgets rule.
  ///
  /// Example:
  ///
  /// ```yaml
  /// solid_lints:
  ///   diagnostics:
  ///     avoid_returning_widgets:
  ///       ignored_types:
  ///         - MultiProvider
  ///         - InheritedTheme
  /// ```
  ///
  /// ```dart
  /// MultiProvider providers(Widget child) => MultiProvider(...); // OK
  /// ```
  final IgnoredTypesListParameter ignoredTypes;

  /// Constructor for [AvoidReturningWidgetsParameters] model
  const AvoidReturningWidgetsParameters({
    required this.exclude,
    required this.ignoredTypes,
  });

  /// Empty [AvoidReturningWidgetsParameters] model, excludes nothing.
  factory AvoidReturningWidgetsParameters.empty() =>
      AvoidReturningWidgetsParameters(
        exclude: ExcludedIdentifiersListParameter(exclude: []),
        ignoredTypes: IgnoredTypesListParameter.empty(),
      );

  /// Method for creating from json data
  factory AvoidReturningWidgetsParameters.fromJson(
    Map<String, Object?> json,
  ) => AvoidReturningWidgetsParameters(
    exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
    ignoredTypes: IgnoredTypesListParameter.fromJson(json),
  );
}
