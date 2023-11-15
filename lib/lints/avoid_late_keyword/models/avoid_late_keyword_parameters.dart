/// A data model class that represents the "avoid late keyword" input
/// parameters.
class AvoidLateKeywordParameters {
  /// Maximum number of parameters
  final bool initializedDynamically;

  static const _defaulInitializedDynamically = false;

  /// Constructor for [AvoidLateKeywordParameters] model
  const AvoidLateKeywordParameters({
    required this.initializedDynamically,
  });

  /// Method for creating from json data
  factory AvoidLateKeywordParameters.fromJson(Map<String, Object?> json) =>
      AvoidLateKeywordParameters(
        initializedDynamically: json['allow-initialized'] as bool? ??
            _defaulInitializedDynamically,
      );
}
