import 'dart:convert';

import 'package:analyzer/file_system/file_system.dart';
import 'package:solid_lints/src/common/parameter_parser/cached_package_config.dart';

/// Helper class to resolve package: URIs to physical file system paths.
class PackageConfigResolver {
  final ResourceProvider _resourceProvider;

  // Caches package_config.json path -> CachedPackageConfig
  final Map<String, CachedPackageConfig> _packagesCache = {};

  /// Creates a new instance of [PackageConfigResolver].
  PackageConfigResolver(this._resourceProvider);

  /// Resolves the absolute directory path for a package URI
  /// (e.g., `package:solid_lints/lib/`).
  String? resolvePackageUri(String baseFilePath, String packageUri) {
    if (!packageUri.startsWith('package:')) return null;

    final pathSegments = Uri.tryParse(packageUri)?.pathSegments;
    if (pathSegments == null || pathSegments.isEmpty) return null;

    final baseDir = _resourceProvider.pathContext.dirname(baseFilePath);
    final packageConfigPath = _findPackageConfig(baseDir);
    if (packageConfigPath == null) return null;

    final [packageName, ...relativePathSegments] = pathSegments;
    final packageRoot = _resolvePackageRoot(packageConfigPath, packageName);
    if (packageRoot == null) return null;

    return _resourceProvider.pathContext.join(
      packageRoot,
      relativePathSegments.join('/'),
    );
  }

  /// Finds the nearest `.dart_tool/package_config.json` file by walking up
  /// the directory tree starting from [startDirectoryPath].
  String? _findPackageConfig(String startDirectoryPath) {
    final pathContext = _resourceProvider.pathContext;
    var currentDirectoryPath = startDirectoryPath;

    while (true) {
      final candidatePath = pathContext.join(
        currentDirectoryPath,
        '.dart_tool',
        'package_config.json',
      );

      final candidateFile = _resourceProvider.getFile(candidatePath);
      if (candidateFile.exists) return candidatePath;

      final parentDir = pathContext.dirname(currentDirectoryPath);
      if (parentDir == currentDirectoryPath || parentDir.isEmpty) return null;

      currentDirectoryPath = parentDir;
    }
  }

  String? _resolvePackageRoot(String packageConfigPath, String packageName) {
    final file = _resourceProvider.getFile(packageConfigPath);
    final modificationStamp = file.exists ? file.modificationStamp : -1;

    var cached = _packagesCache[packageConfigPath];
    if (cached == null || cached.modificationStamp != modificationStamp) {
      final packageMap = _parsePackageConfig(file);
      cached = CachedPackageConfig(
        modificationStamp: modificationStamp,
        packages: packageMap,
      );
      _packagesCache[packageConfigPath] = cached;
    }
    return cached.packages[packageName];
  }

  /// Reads and parses the `.dart_tool/package_config.json` configuration file.
  ///
  /// Returns a map associating each package name (e.g., 'lints') with its
  /// absolute physical path to the `lib/` directory on disk.
  Map<String, String> _parsePackageConfig(File file) {
    if (!file.exists) return const {};

    try {
      if (jsonDecode(file.readAsStringSync()) case {
        'packages': final List<dynamic> packagesList,
      }) {
        return {
          for (final package in packagesList)
            if (package case {
              'name': final String name,
              'rootUri': final String rootUriString,
              'packageUri': final String packageUriString,
            })
              if (_resolveRootUriFrom(
                    rootUriString: rootUriString,
                    filePath: file.path,
                  )
                  case final resolvedRootUri?)
                name: _resourceProvider.pathContext.join(
                  resolvedRootUri,
                  packageUriString,
                ),
        };
      }
    } catch (_) {}

    return const {};
  }

  String? _resolveRootUriFrom({
    required String rootUriString,
    required String filePath,
  }) {
    final rootUri = Uri.parse(rootUriString);
    final resolvedRootUri = rootUri.isAbsolute
        ? rootUri
        : _resourceProvider.pathContext.toUri(filePath).resolveUri(rootUri);

    if (resolvedRootUri.isScheme('file')) {
      return _resourceProvider.pathContext.fromUri(resolvedRootUri);
    }

    return null;
  }
}
