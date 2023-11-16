part '_config_parser.dart';

/// A data model class that represents the "avoid late keyword" input
/// parameters.
class AvoidLateKeywordParameters {
  /// Allow to dynamically initialize
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
        allowInitialized: _ConfigParser.parseAllowInitialized(json),
        ignoredTypes: _ConfigParser.parseIgnoredTypes(json),
      );
}
