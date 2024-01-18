/// A data model class that represents the "avoid late keyword" input
/// parameters.
class AvoidLateKeywordParameters {
  /// Allow immediately initialised late variables.
  ///
  /// ```dart
  /// late var ok = 0; // ok when allowInitialized == true
  /// late var notOk; // initialized elsewhere, not allowed
  /// ```
  final bool allowInitialized;

  /// Types that would be ignored by avoid-late rule
  final Iterable<String> ignoredTypes;

  /// Constructor for [AvoidLateKeywordParameters] model
  const AvoidLateKeywordParameters({
    this.allowInitialized = false,
    this.ignoredTypes = const [],
  });

  /// Method for creating from json data
  factory AvoidLateKeywordParameters.fromJson(Map<String, Object?> json) =>
      AvoidLateKeywordParameters(
        allowInitialized: json['allow_initialized'] as bool? ?? false,
        ignoredTypes:
            List<String>.from(json['ignored_types'] as Iterable? ?? []),
      );
}
