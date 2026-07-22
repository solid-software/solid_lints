/// Cached rules for a dart package
class CachedPackageRules {
  /// The last modification stamp of the analysis options file
  final int modificationStamp;

  /// Cached rules options by rule name for the package
  final Map<String, Map<String, Object?>> rules;

  /// Rules that are explicitly disabled
  final Set<String> disabledRules;

  /// Creates an instance of [CachedPackageRules]
  const CachedPackageRules({
    required this.modificationStamp,
    required this.rules,
    required this.disabledRules,
  });
}
