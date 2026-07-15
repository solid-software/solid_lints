import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/path_utils.dart';

/// Service responsible for persisting and loading the duplicate code hash
/// cache.
class HashCacheStorage {
  static const _cacheDirName = '.dart_tool/solid_lints';
  static const _cacheFileName = 'duplicate_index.json';

  static String _filePath(String packageRoot) =>
      p.join(packageRoot, _cacheDirName, _cacheFileName);

  /// Loads the cached index from disk for the given [packageRoot].
  ///
  /// Returns `null` if the cache file does not exist, is corrupted, or fails
  /// to load.
  static Map<String, FileCacheEntry>? load(
    String packageRoot,
    AvoidDuplicateCodeParameters currentParams,
  ) {
    try {
      final file = File(_filePath(packageRoot));
      if (!file.existsSync()) return null;

      final content = file.readAsStringSync();
      final jsonMap = jsonDecode(content) as Map<String, Object?>;

      // Validate config
      final cachedConfig = jsonMap['config'];
      if (cachedConfig is! Map<String, Object?>) {
        return null;
      }

      final currentConfig = currentParams.toJson();
      if (!const DeepCollectionEquality().equals(cachedConfig, currentConfig)) {
        // Configuration mismatch -> discard cache
        return null;
      }

      final filesMap = jsonMap['files'];
      if (filesMap is! Map<String, Object?>) {
        return null;
      }

      final result = <String, FileCacheEntry>{};
      for (final MapEntry(:key, :value) in filesMap.entries) {
        final absoluteKey = PathUtils.normalizePath(key, packageRoot);

        if (value is Map<String, Object?>) {
          try {
            result[absoluteKey] = FileCacheEntry.fromJson(value);
          } catch (_) {
            // Skip corrupted entries
          }
        }
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Saves the [index] to disk for the given [packageRoot].
  static void save(
    String packageRoot,
    Map<String, FileCacheEntry> index,
    AvoidDuplicateCodeParameters currentParams,
  ) {
    try {
      final directory = Directory(p.join(packageRoot, _cacheDirName));
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file = File(_filePath(packageRoot));

      final filesMap = <String, Object?>{};
      for (final entry in index.entries) {
        final relativeKey = p.isAbsolute(entry.key)
            ? p.relative(entry.key, from: packageRoot)
            : entry.key;
        filesMap[relativeKey] = entry.value.toJson();
      }

      final data = {
        'version': 1,
        'config': currentParams.toJson(),
        'files': filesMap,
      };

      file.writeAsStringSync(jsonEncode(data));
    } on FileSystemException {
      // Fail silently to avoid breaking analysis server
    }
  }

  /// Deletes the cache file for [packageRoot] if it exists.
  static void delete(String packageRoot) {
    try {
      final file = File(_filePath(packageRoot));
      if (file.existsSync()) {
        file.deleteSync();
      }
    } on FileSystemException {
      // Fail silently
    }
  }
}
