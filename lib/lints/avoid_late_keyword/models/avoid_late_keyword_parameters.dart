/// A data model class that represents the "avoid late keyword" input
/// parameters.
class AvoidLateKeywordParameters {
  /// Maximum number of parameters
  final bool allowInitialized;

  static const _defaultAllowInitialized = false;

  /// Constructor for [AvoidLateKeywordParameters] model
  const AvoidLateKeywordParameters({
    required this.allowInitialized,
  });

  /// Method for creating from json data
  factory AvoidLateKeywordParameters.fromJson(Map<String, Object?> json) =>
      AvoidLateKeywordParameters(
        allowInitialized: json['allow-initialized'] as bool? ??
            _defaultAllowInitialized,
      );
}
