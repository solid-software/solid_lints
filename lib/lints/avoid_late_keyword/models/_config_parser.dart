part of 'avoid_late_keyword_parameters.dart';

class _ConfigParser {
  static const _allowInitializedConfig = 'allow_initialized';
  static const _ignoredTypesConfig = 'ignored_types';

  static bool parseAllowInitialized(Map<String, Object?> config) =>
      config[_allowInitializedConfig] as bool? ?? false;

  static Iterable<String> parseIgnoredTypes(Map<String, Object?> config) =>
      config.containsKey(_ignoredTypesConfig) &&
              config[_ignoredTypesConfig] is Iterable
          ? List<String>.from(config[_ignoredTypesConfig] as Iterable)
          : <String>['AnimationController'];
}
