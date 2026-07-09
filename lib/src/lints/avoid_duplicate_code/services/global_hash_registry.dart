import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/cross_file_match.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/hash_cache_storage.dart';

/// A singleton registry that stores structural hashes for all analyzed files.
///
/// This registry lives as long as the plugin isolate, enabling cross-file
/// clone detection on a "best-effort" basis — duplicates are detected
/// against files that have already been analyzed in the current session.
///
/// When a file is analyzed, its hash entries are stored in the registry.
/// Subsequent file analyses check their hashes against the registry to find
/// cross-file duplicates.
class GlobalHashRegistry {
  /// Singleton instance — lives as long as the plugin isolate.
  static final instance = GlobalHashRegistry._();

  /// Internal index: filePath → FileCacheEntry.
  final _index = <String, FileCacheEntry>{};

  /// Auxiliary inverted index: hash → Set<DuplicateLocation>.
  final _hashToLocations = <int, Set<DuplicateLocation>>{};

  final _loadedRoots = <String>{};

  Timer? _saveTimer;

  /// Whether to automatically clean up files that do not exist physically on
  /// disk.
  ///
  /// Set to `false` in tests using a virtual resource provider.
  bool enablePhysicalFileCleanup = true;

  GlobalHashRegistry._();

  void _addToInvertedIndex(String absoluteFilePath, List<HashEntry> entries) {
    for (final entry in entries) {
      _hashToLocations.putIfAbsent(entry.hash, () => {}).add(
            DuplicateLocation(
              entry: entry,
              filePath: absoluteFilePath,
            ),
          );
    }
  }

  void _removeFromInvertedIndex(
    String absoluteFilePath,
    List<HashEntry> entries,
  ) {
    for (final entry in entries) {
      final set = _hashToLocations[entry.hash];
      if (set != null) {
        set.removeWhere((loc) => loc.filePath == absoluteFilePath);
        if (set.isEmpty) {
          _hashToLocations.remove(entry.hash);
        }
      }
    }
  }

  void _ensureLoaded(String packageRoot) {
    if (_loadedRoots.contains(packageRoot)) return;
    _loadedRoots.add(packageRoot);
    final cached = HashCacheStorage.load(packageRoot);
    if (cached != null) {
      _index.addAll(cached);

      // Clean up files that were physically deleted once upon loading cache
      final deletedFiles = <String>[];
      for (final path in cached.keys) {
        if (enablePhysicalFileCleanup && !File(path).existsSync()) {
          deletedFiles.add(path);
        }
      }
      for (final file in deletedFiles) {
        _index.remove(file);
      }

      for (final MapEntry(:key, :value) in _index.entries) {
        _addToInvertedIndex(key, value.entries);
      }

      if (deletedFiles.isNotEmpty) {
        _scheduleSave(packageRoot);
      }
    }
  }

  /// Returns the cached modification stamp for [filePath], or `null` if not indexed.
  int? getModificationStamp(String filePath, {String? packageRoot}) {
    final root = packageRoot ?? Directory.current.path;
    _ensureLoaded(root);
    final absoluteFilePath = p.isAbsolute(filePath)
        ? p.normalize(filePath)
        : p.normalize(p.join(root, filePath));
    return _index[absoluteFilePath]?.modificationStamp;
  }

  /// Returns the cached entries for [filePath], or `null` if not indexed.
  List<HashEntry>? getFileEntries(String filePath, {String? packageRoot}) {
    final root = packageRoot ?? Directory.current.path;
    _ensureLoaded(root);
    final absoluteFilePath = p.isAbsolute(filePath)
        ? p.normalize(filePath)
        : p.normalize(p.join(root, filePath));
    return _index[absoluteFilePath]?.entries;
  }

  /// Updates the hash entries for [filePath], replacing any previous entries.
  void updateFile(
    String filePath,
    List<HashEntry> entries, {
    required int modificationStamp,
    String? packageRoot,
  }) {
    final root = packageRoot ?? Directory.current.path;
    _ensureLoaded(root);
    final absoluteFilePath = p.isAbsolute(filePath)
        ? p.normalize(filePath)
        : p.normalize(p.join(root, filePath));

    final oldEntry = _index[absoluteFilePath];
    if (oldEntry != null) {
      _removeFromInvertedIndex(absoluteFilePath, oldEntry.entries);
    }

    _index[absoluteFilePath] = FileCacheEntry(
      modificationStamp: modificationStamp,
      entries: entries,
    );
    _addToInvertedIndex(absoluteFilePath, entries);
    _scheduleSave(root);
  }

  /// Finds cross-file duplicates for [currentEntries] against all other
  /// indexed files (excluding [currentFilePath]).
  ///
  /// Returns a list of [CrossFileMatch] objects, one for each duplicate found.
  List<CrossFileMatch> findCrossFileMatches(
    String currentFilePath,
    List<HashEntry> currentEntries, {
    bool Function(String filePath)? isFileExcluded,
    String? packageRoot,
  }) {
    final root = packageRoot ?? Directory.current.path;
    _ensureLoaded(root);

    final absoluteCurrentFilePath = p.isAbsolute(currentFilePath)
        ? p.normalize(currentFilePath)
        : p.normalize(p.join(root, currentFilePath));

    final matches = <CrossFileMatch>[];
    final filesToRemove = <String>{};

    for (final entry in currentEntries) {
      final duplicates = <DuplicateLocation>[];

      final locations = _hashToLocations[entry.hash];
      if (locations != null) {
        for (final loc in locations) {
          final key = loc.filePath;
          if (key == absoluteCurrentFilePath) continue;

          // Check if deleted or excluded on demand only for matched locations
          final isDeleted = enablePhysicalFileCleanup && !File(key).existsSync();
          final isExcluded = isFileExcluded != null && isFileExcluded(key);

          if (isDeleted || isExcluded) {
            filesToRemove.add(key);
            continue;
          }

          if (!key.startsWith(root)) continue;
          if (key.contains('.dart_tool/')) {
            if (!key.contains('.dart_tool/generated_test/')) continue;
            if (p.dirname(key) != p.dirname(absoluteCurrentFilePath)) continue;
          }

          duplicates.add(loc);
        }
      }

      if (duplicates.isNotEmpty) {
        matches.add(
          CrossFileMatch(
            currentEntry: entry,
            duplicates: duplicates,
          ),
        );
      }
    }

    if (filesToRemove.isNotEmpty) {
      for (final file in filesToRemove) {
        final oldEntry = _index[file];
        if (oldEntry != null) {
          _removeFromInvertedIndex(file, oldEntry.entries);
        }
        _index.remove(file);
      }
      _scheduleSave(root);
    }

    return matches;
  }

  /// Removes [filePath] from the index.
  void removeFile(String filePath, {String? packageRoot}) {
    final root = packageRoot ?? Directory.current.path;
    _ensureLoaded(root);
    final absoluteFilePath = p.isAbsolute(filePath)
        ? p.normalize(filePath)
        : p.normalize(p.join(root, filePath));
    final oldEntry = _index[absoluteFilePath];
    if (oldEntry != null) {
      _removeFromInvertedIndex(absoluteFilePath, oldEntry.entries);
    }
    _index.remove(absoluteFilePath);
    _scheduleSave(root);
  }

  /// The number of files currently indexed.
  int get fileCount => _index.length;

  /// Clears the entire index and deletes the persistent cache file.
  ///
  /// Primarily used in tests to ensure test isolation.
  void clear() {
    _saveTimer?.cancel();
    _loadedRoots.clear();
    _index.clear();
    _hashToLocations.clear();
    HashCacheStorage.delete(Directory.current.path);
    try {
      final file = File(
        '${Directory.current.path}/.dart_tool/solid_lints/duplicate_inverted_index.json',
      );
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  void _scheduleSave(String packageRoot) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _performSave(packageRoot);
    });
  }

  void _performSave(String packageRoot) {
    // Filter _index for files belonging to this packageRoot
    final subset = <String, FileCacheEntry>{
      for (final MapEntry(:key, :value) in _index.entries)
        if (key.startsWith(packageRoot)) key: value
    };

    HashCacheStorage.save(packageRoot, subset);

    // Save inverted index to duplicate_inverted_index.json
    try {
      final jsonInverted = <String, List<Map<String, Object?>>>{};
      _hashToLocations.forEach((hash, locations) {
        final packageLocations = locations
            .where((loc) => loc.filePath.startsWith(packageRoot))
            .toList();
        if (packageLocations.isEmpty) return;

        jsonInverted[hash.toString()] = packageLocations.map((loc) {
          final relativePath = p.isAbsolute(loc.filePath)
              ? p.relative(loc.filePath, from: packageRoot)
              : loc.filePath;
          return {
            'filePath': relativePath,
            'entry': loc.entry.toJson(),
          };
        }).toList();
      });

      final file = File(
        '$packageRoot/.dart_tool/solid_lints/duplicate_inverted_index.json',
      );
      if (jsonInverted.isEmpty) {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } else {
        final directory = file.parent;
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        file.writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(jsonInverted),
        );
      }
    } catch (_) {
      // Fail silently to avoid breaking analysis server
    }
  }
}
