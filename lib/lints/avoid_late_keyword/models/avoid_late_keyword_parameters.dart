/// A data model class that represents the "avoid late keyword" input
/// parameters.
class AvoidLateKeywordParameters {
  /// Maximum number of parameters
  final bool allowInitialized;

  /// Constructor for [AvoidLateKeywordParameters] model
  const AvoidLateKeywordParameters({
   this.allowInitialized = false,
  });

  /// Method for creating from json data
  factory AvoidLateKeywordParameters.fromJson(Map<String, Object?> json) =>
      AvoidLateKeywordParameters(
        allowInitialized: json['allow_initialized'] as bool?,
      );
}
