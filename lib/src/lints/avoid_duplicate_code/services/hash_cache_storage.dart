import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';

/// Service responsible for persisting and loading the duplicate code hash
/// cache.
class HashCacheStorage {
  static String _filePath(String packageRoot) =>
      '$packageRoot/.dart_tool/solid_lints/duplicate_index.json';

  /// Loads the cached index from disk for the given [packageRoot].
  ///
  /// Returns `null` if the cache file does not exist, is corrupted, or fails
  /// to load.
  static Map<String, FileCacheEntry>? load(String packageRoot) {
    final stopwatch = Stopwatch()..start();
    final startTime = DateTime.now();
    try {
      final file = File(_filePath(packageRoot));
      if (!file.existsSync()) return null;

      final content = file.readAsStringSync();
      final jsonMap = jsonDecode(content) as Map<String, Object?>;

      final result = <String, FileCacheEntry>{};
      for (final MapEntry(:key, :value) in jsonMap.entries) {
        final absoluteKey = p.isAbsolute(key)
            ? p.normalize(key)
            : p.normalize(p.join(packageRoot, key));

        if (value is Map<String, Object?>) {
          try {
            result[absoluteKey] = FileCacheEntry.fromJson(value);
          } catch (_) {
            // Skip corrupted entries
          }
        }
      }
      stopwatch.stop();
      _writeLoadLog(
        packageRoot,
        startTime,
        stopwatch.elapsedMilliseconds,
        result.length,
      );
      return result;
    } catch (_) {
      stopwatch.stop();
      _writeLoadLog(packageRoot, startTime, stopwatch.elapsedMilliseconds, -1);
      return null;
    }
  }

  static void _writeLoadLog(
    String packageRoot,
    DateTime time,
    int elapsedMs,
    int filesCount,
  ) {
    try {
      final logFile = File(
        '$packageRoot/.dart_tool/solid_lints/duplicate_index_load.log',
      );
      final logLine =
          '${time.toIso8601String()}: Loaded map in ${elapsedMs}ms '
          '(files: ${filesCount >= 0 ? filesCount : 'failed'})\n';
      logFile.writeAsStringSync(logLine, mode: FileMode.append);
    } catch (_) {
      // Fail silently
    }
  }

  /// Saves the [index] to disk for the given [packageRoot].
  static void save(String packageRoot, Map<String, FileCacheEntry> index) {
    try {
      final cacheDir = '$packageRoot/.dart_tool/solid_lints';
      final directory = Directory(cacheDir);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file = File(_filePath(packageRoot));
      if (index.isEmpty) {
        file.writeAsStringSync('{}');
        return;
      }

      final buffer = StringBuffer('{\n');
      final entriesList = index.entries.toList();
      for (var i = 0; i < entriesList.length; i++) {
        final entry = entriesList[i];
        final relativeKey = p.isAbsolute(entry.key)
            ? p.relative(entry.key, from: packageRoot)
            : entry.key;
        final listJson = jsonEncode(entry.value.toJson());

        buffer.write('  ${jsonEncode(relativeKey)}: $listJson');
        if (i < entriesList.length - 1) {
          buffer.write(',\n');
        } else {
          buffer.write('\n');
        }
      }
      buffer.write('}');
      file.writeAsStringSync(buffer.toString());
    } catch (_) {
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
    } catch (_) {
      // Fail silently
    }
  }
}
