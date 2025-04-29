/// A data model class that represents the "prefer factmatch file name" input
/// parameters
class PreferMatchFileNameParameters {
  /// A list of methods that should be excluded from the lint.
  final Iterable<String> excludeEntity;

  static const bool _defaultIgnoreExtensionsValue = false;

  /// Constructor for [PreferMatchFileNameParameters] model
  const PreferMatchFileNameParameters({
    required this.excludeEntity,
  });

  /// Method for creating from json data
  factory PreferMatchFileNameParameters.fromJson(Map<String, Object?> json) =>
      PreferMatchFileNameParameters(
        excludeEntity: (json['exclude_entity'] as Iterable?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
