/// Cached package configuration with its modification stamp.
class CachedPackageConfig {
  /// The modification stamp of the package_config.json file when cached.
  final int modificationStamp;

  /// The parsed package mappings (packageName -> absolute path to lib).
  final Map<String, String> packages;

  /// Creates a new instance of [CachedPackageConfig].
  const CachedPackageConfig({
    required this.modificationStamp,
    required this.packages,
  });
}
