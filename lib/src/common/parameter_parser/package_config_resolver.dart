import 'dart:convert';
import 'package:analyzer/file_system/file_system.dart';

/// Helper class to resolve package: URIs to physical file system paths.
class PackageConfigResolver {
  final ResourceProvider _resourceProvider;

  // Caches directory path -> nearest package_config.json path
  final Map<String, String?> _configPathCache = {};

  // Caches package_config.json path -> Map<packageName, packageRootPath>
  final Map<String, Map<String, String>> _packagesCache = {};

  /// Creates a new instance of [PackageConfigResolver].
  PackageConfigResolver(this._resourceProvider);

  /// Resolves the absolute directory path for a package URI
  /// (e.g., `package:solid_lints/lib/`).
  String? resolvePackageUri(String baseFilePath, String packageUri) {
    if (!packageUri.startsWith('package:')) return null;

    final uri = Uri.parse(packageUri);
    if (uri.pathSegments.isEmpty) return null;

    final packageName = uri.pathSegments.first;
    final relativePath = uri.pathSegments.skip(1).join('/');

    final baseDir = _resourceProvider.pathContext.dirname(baseFilePath);
    final packageConfigPath = _findPackageConfig(baseDir);
    if (packageConfigPath == null) return null;

    final packageRoot = _resolvePackageRoot(packageConfigPath, packageName);
    if (packageRoot == null) return null;

    return _resourceProvider.pathContext.join(packageRoot, relativePath);
  }

  /// Finds the nearest `.dart_tool/package_config.json` file by walking up
  /// the directory tree starting from [startDirectoryPath].
  ///
  /// Results (including `null`) are cached in [_configPathCache] to avoid
  /// redundant filesystem walks.
  String? _findPackageConfig(String startDirectoryPath) {
    final cached = _configPathCache[startDirectoryPath];
    if (cached != null || _configPathCache.containsKey(startDirectoryPath)) {
      return cached;
    }

    final pathContext = _resourceProvider.pathContext;
    var currentDirectoryPath = startDirectoryPath;

    while (currentDirectoryPath.isNotEmpty) {
      final candidatePath = pathContext.join(
        currentDirectoryPath,
        '.dart_tool',
        'package_config.json',
      );
      final candidateFile = _resourceProvider.getFile(candidatePath);

      if (candidateFile.exists) {
        return _configPathCache[startDirectoryPath] = candidatePath;
      }

      final parentDir = pathContext.dirname(currentDirectoryPath);
      if (parentDir == currentDirectoryPath) {
        break;
      }
      currentDirectoryPath = parentDir;
    }

    return _configPathCache[startDirectoryPath] = null;
  }

  String? _resolvePackageRoot(String packageConfigPath, String packageName) {
    var packageMap = _packagesCache[packageConfigPath];
    if (packageMap == null) {
      packageMap = _parsePackageConfig(packageConfigPath);
      _packagesCache[packageConfigPath] = packageMap;
    }
    return packageMap[packageName];
  }

  /// Reads and parses the `.dart_tool/package_config.json` configuration file.
  ///
  /// Returns a map associating each package name (e.g., 'lints') with its
  /// absolute physical path to the `lib/` directory on disk.
  Map<String, String> _parsePackageConfig(String packageConfigPath) {
    final file = _resourceProvider.getFile(packageConfigPath);
    if (!file.exists) return const {};

    try {
      final content = file.readAsStringSync();
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic>) return const {};

      final packagesList = json['packages'];
      if (packagesList is! List<dynamic>) return const {};

      final result = <String, String>{};

      for (final package in packagesList) {
        if (package is! Map<String, dynamic>) continue;

        final name = package['name'];
        final rootUriString = package['rootUri'];
        final packageUriString = package['packageUri'];

        if (name is! String ||
            rootUriString is! String ||
            packageUriString is! String) {
          continue;
        }

        final rootUri = Uri.parse(rootUriString);
        final resolvedRootUri = rootUri.isAbsolute
            ? rootUri
            : Uri.file(packageConfigPath).resolveUri(rootUri);

        if (resolvedRootUri.isScheme('file')) {
          result[name] = _resourceProvider.pathContext.join(
            resolvedRootUri.toFilePath(),
            packageUriString,
          );
        }
      }
      return result;
    } catch (_) {
      return const {};
    }
  }
}
