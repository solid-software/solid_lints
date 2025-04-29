/// A data model class that represents the "prefer factmatch file name" input
/// parameters
class PreferMatchFileNameParameters {
  /// A variable that indicates whether to ignore extensions
  final bool ignoreExtensions;

  /// A list of methods that should be excluded from the lint.
  final Iterable<String> excludeEntity;

  static const bool _defaultIgnoreExtensionsValue = false;

  /// Constructor for [PreferMatchFileNameParameters] model
  const PreferMatchFileNameParameters({
    required this.ignoreExtensions,
    required this.excludeEntity,
  });

  /// Method for creating from json data
  factory PreferMatchFileNameParameters.fromJson(Map<String, Object?> json) =>
      PreferMatchFileNameParameters(
        ignoreExtensions:
            json['ignore_extensions'] as bool? ?? _defaultIgnoreExtensionsValue,
        excludeEntity: (json['exclude_entity'] as Iterable?)
            ?.map((e) => e.toString())
            .toList() ?? [],
      );
}
