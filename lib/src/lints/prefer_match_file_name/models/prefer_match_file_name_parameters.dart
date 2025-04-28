/// A data model class that represents the "prefer factmatch file name" input
/// parameters
class PreferMatchFileNameParameters {
  /// A variable that indicates whether to ignore extensions
  final bool ignoreExtensions;

  static const bool _defaultIgnoreExtensionsValue = false;

  /// Constructor for [PreferMatchFileNameParameters] model
  const PreferMatchFileNameParameters({
    required this.ignoreExtensions,
  });

  /// Method for creating from json data
  factory PreferMatchFileNameParameters.fromJson(Map<String, Object?> json) =>
      PreferMatchFileNameParameters(
        ignoreExtensions:
            json['ignore_extensions'] as bool? ?? _defaultIgnoreExtensionsValue,
      );
}
