import 'dart:convert';

import 'package:analyzer/file_system/file_system.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/path_utils.dart';
import 'package:solid_lints/src/utils/function_utils.dart';
import 'package:solid_lints/src/utils/resource_provider_utils.dart';

/// Service responsible for persisting and loading the duplicate code hash
/// cache.
class HashCacheStorage {
  static const _cacheDirName = '.dart_tool/solid_lints';
  static const _cacheFileName = 'duplicate_index.json';

  /// The root directory of the package being analyzed.
  final String packageRoot;

  /// The resource provider used for file system operations.
  final ResourceProvider resourceProvider;

  /// The current configuration parameters.
  final AvoidDuplicateCodeParameters currentParams;

  File get _file => resourceProvider.getFile(
    resourceProvider.pathContext.join(
      packageRoot,
      _cacheDirName,
      _cacheFileName,
    ),
  );

  /// Constructor for [HashCacheStorage].
  HashCacheStorage({
    required this.packageRoot,
    required this.resourceProvider,
    AvoidDuplicateCodeParameters? currentParams,
  }) : currentParams = currentParams ?? AvoidDuplicateCodeParameters.empty();

  /// Loads the cached index from disk for [packageRoot].
  ///
  /// Returns `null` if the cache file does not exist, is corrupted, or fails
  /// to load.
  Map<String, FileCacheEntry>? load() => FunctionUtils.tryOrNull(_load);

  Map<String, FileCacheEntry> _load() {
    if (jsonDecode(_file.readAsStringSync()) case {
      'config': final cachedConfig,
      'files': final Map<String, Object?> filesMap,
    }) {
      if (!const DeepCollectionEquality().equals(
        cachedConfig,
        currentParams.toJson(),
      )) {
        throw ArgumentError('Configuration mismatch');
      }

      return {
        for (final MapEntry(:key, :value) in filesMap.entries)
          if (PathUtils.normalizePath(key, packageRoot) case final absoluteKey)
            if (value is Map<String, Object?>)
              if (FunctionUtils.tryOrNull(() => FileCacheEntry.fromJson(value))
                  case final parsed?)
                absoluteKey: parsed,
      };
    }

    throw ArgumentError('Bad json');
  }

  /// Saves the [index] to disk for [packageRoot].
  void save(Map<String, FileCacheEntry> index) => FunctionUtils.tryOrNull(
    () {
      resourceProvider.ensureFolderExists(packageRoot, _cacheDirName);
      _file.writeAsStringSync(
        jsonEncode({
          'version': 1,
          'config': currentParams.toJson(),
          'files': index.map(
            (k, v) => MapEntry(
              PathUtils.relativePath(k, packageRoot),
              v.toJson(),
            ),
          ),
        }),
      );
    },
  );

  /// Deletes the cache file for [packageRoot] if it exists.
  void delete() => FunctionUtils.tryOrNull(_file.delete);
}
