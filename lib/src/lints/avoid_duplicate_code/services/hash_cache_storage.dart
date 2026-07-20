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
abstract final class HashCacheStorage {
  static const _cacheDirName = '.dart_tool/solid_lints';
  static const _cacheFileName = 'duplicate_index.json';

  static File _getFile(
    String packageRoot,
    ResourceProvider resourceProvider,
  ) => resourceProvider.getFile(
    resourceProvider.pathContext.join(
      packageRoot,
      _cacheDirName,
      _cacheFileName,
    ),
  );

  /// Loads the cached index from disk for the given [packageRoot].
  ///
  /// Returns `null` if the cache file does not exist, is corrupted, or fails
  /// to load.
  static Map<String, FileCacheEntry>? load(
    String packageRoot,
    AvoidDuplicateCodeParameters currentParams,
    ResourceProvider resourceProvider,
  ) => FunctionUtils.tryOrNull(
    () => _load(
      packageRoot,
      currentParams,
      resourceProvider,
    ),
  );

  static Map<String, FileCacheEntry> _load(
    String packageRoot,
    AvoidDuplicateCodeParameters currentParams,
    ResourceProvider resourceProvider,
  ) {
    if (jsonDecode(_getFile(packageRoot, resourceProvider).readAsStringSync())
        case {
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

  /// Saves the [index] to disk for the given [packageRoot].
  static void save(
    String packageRoot,
    Map<String, FileCacheEntry> index,
    AvoidDuplicateCodeParameters currentParams,
    ResourceProvider resourceProvider,
  ) => FunctionUtils.tryOrNull(
    () {
      resourceProvider.ensureFolderExists(packageRoot, _cacheDirName);
      _getFile(packageRoot, resourceProvider).writeAsStringSync(
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
  static void delete(
    String packageRoot,
    ResourceProvider resourceProvider,
  ) => FunctionUtils.tryOrNull(
    () => _getFile(packageRoot, resourceProvider).delete(),
  );
}
