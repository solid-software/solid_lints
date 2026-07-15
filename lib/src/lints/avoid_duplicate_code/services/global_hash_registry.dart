import 'dart:io';

import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/cross_file_match.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/hash_cache_storage.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/debouncer.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/path_utils.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/avoid_duplicate_code_visitor.dart';

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
  static const _saveDebounceDuration = Duration(milliseconds: 500);

  /// Singleton instance — lives as long as the plugin isolate.
  static final instance = GlobalHashRegistry._();

  /// Whether to automatically clean up files that do not exist physically on
  /// disk.
  ///
  /// Set to `false` in tests using a virtual resource provider.
  bool enablePhysicalFileCleanup = true;

  /// Internal index: filePath → FileCacheEntry.
  final _index = <String, FileCacheEntry>{};

  /// Auxiliary inverted index: hash → Set<DuplicateLocation>.
  final _hashToLocations = <int, Set<DuplicateLocation>>{};

  final _loadedRoots = <String, AvoidDuplicateCodeParameters>{};
  late final _saveDebouncer = Debouncer(_saveDebounceDuration);

  AvoidDuplicateCodeParameters? _currentParams;

  GlobalHashRegistry._();

  /// The number of files currently indexed.
  int get fileCount => _index.length;

  String _getRoot(String? packageRoot) => packageRoot ?? Directory.current.path;

  void _addToInvertedIndex(String absoluteFilePath, List<HashEntry> entries) {
    for (final entry in entries) {
      _hashToLocations
          .putIfAbsent(entry.hash, () => {})
          .add(
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

  void _ensureLoaded(
    String packageRoot, [
    AvoidDuplicateCodeParameters? currentParams,
  ]) {
    final params = currentParams ?? AvoidDuplicateCodeParameters.empty();
    final previousParams = _loadedRoots[packageRoot];

    // If already loaded with the same parameters, skip.
    if (previousParams != null && previousParams == params) return;

    // If parameters changed, clear entries for this root first.
    if (previousParams != null) {
      _clearEntriesForRoot(packageRoot);
    }

    _loadedRoots[packageRoot] = params;
    _currentParams = params;
    final cached = HashCacheStorage.load(packageRoot, params);
    if (cached != null) {
      _index.addAll(cached);

      // Clean up files that were physically deleted once upon loading cache
      final deletedFiles = <String>{};
      for (final path in cached.keys) {
        if (enablePhysicalFileCleanup && !File(path).existsSync()) {
          deletedFiles.add(path);
        }
      }
      for (final file in deletedFiles) {
        _index.remove(file);
      }

      for (final MapEntry(:key, :value) in cached.entries) {
        if (deletedFiles.contains(key)) continue;
        _addToInvertedIndex(key, value.entries);
      }

      if (deletedFiles.isNotEmpty) {
        _scheduleSave(packageRoot, params);
      }
    }
  }

  void _clearEntriesForRoot(String packageRoot) {
    final keysToRemove = <String>[];
    for (final key in _index.keys) {
      if (PathUtils.isWithinOrEqual(packageRoot, key)) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      final oldEntry = _index[key];
      if (oldEntry != null) {
        _removeFromInvertedIndex(key, oldEntry.entries);
      }
      _index.remove(key);
    }
  }

  String _resolveAndLoad(
    String filePath,
    String? packageRoot,
    AvoidDuplicateCodeParameters? parameters,
  ) {
    final root = _getRoot(packageRoot);
    _ensureLoaded(root, parameters);
    return PathUtils.normalizePath(filePath, root);
  }

  /// Returns the cached modification stamp for [filePath], or `null` if no
  /// indexed.
  int? getModificationStamp(
    String filePath, {
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) {
    final absoluteFilePath = _resolveAndLoad(filePath, packageRoot, parameters);
    return _index[absoluteFilePath]?.modificationStamp;
  }

  /// Returns the cached entries for [filePath], or `null` if not indexed.
  List<HashEntry>? getFileEntries(
    String filePath, {
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) {
    final absoluteFilePath = _resolveAndLoad(filePath, packageRoot, parameters);
    return _index[absoluteFilePath]?.entries;
  }

  /// Updates the hash entries for [filePath], replacing any previous entries.
  void updateFile(
    String filePath,
    List<HashEntry> entries, {
    required int modificationStamp,
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) {
    final root = _getRoot(packageRoot);
    final absoluteFilePath = _resolveAndLoad(filePath, packageRoot, parameters);

    final oldEntry = _index[absoluteFilePath];
    if (oldEntry != null) {
      _removeFromInvertedIndex(absoluteFilePath, oldEntry.entries);
    }

    _index[absoluteFilePath] = FileCacheEntry(
      modificationStamp: modificationStamp,
      entries: entries,
    );
    _addToInvertedIndex(absoluteFilePath, entries);
    _scheduleSave(root, parameters);
  }

  /// Finds cross-file duplicates for [currentEntries] against all other
  /// indexed files (excluding [currentFilePath]).
  ///
  /// Returns a list of [CrossFileMatch] objects, one for each duplicate found.
  List<CrossFileMatch> findCrossFileMatches(
    String currentFilePath,
    List<HashEntry> currentEntries, {
    AvoidDuplicateCodeParameters? parameters,
    bool Function(String filePath)? isFileExcluded,
    String? packageRoot,
  }) {
    final root = _getRoot(packageRoot);
    final absoluteCurrentFilePath = _resolveAndLoad(
      currentFilePath,
      packageRoot,
      parameters,
    );

    final matches = <CrossFileMatch>[];
    final filesToRemove = <String>{};
    final fileStatusCache = <String, bool>{};

    for (final entry in currentEntries) {
      final duplicates = <DuplicateLocation>[];

      final locations = _hashToLocations[entry.hash];
      if (locations != null) {
        for (final loc in locations) {
          final key = loc.filePath;
          if (key == absoluteCurrentFilePath) continue;

          // Check if deleted or excluded on demand only for matched locations
          bool? isInvalid = fileStatusCache[key];
          if (isInvalid == null) {
            final isDeleted =
                enablePhysicalFileCleanup && !File(key).existsSync();
            final isExcluded = isFileExcluded != null && isFileExcluded(key);
            isInvalid = isDeleted || isExcluded;
            fileStatusCache[key] = isInvalid;
          }

          if (isInvalid) {
            filesToRemove.add(key);
            continue;
          }

          if (!PathUtils.isWithinOrEqual(root, key)) continue;

          // Verify tokenCount to guard against hash collisions.
          if (loc.entry.tokenCount != entry.tokenCount) continue;

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
      _scheduleSave(root, parameters);
    }

    return matches;
  }

  /// Removes [filePath] from the index.
  void removeFile(
    String filePath, {
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) {
    final root = _getRoot(packageRoot);
    final absoluteFilePath = _resolveAndLoad(filePath, packageRoot, parameters);
    final oldEntry = _index[absoluteFilePath];
    if (oldEntry != null) {
      _removeFromInvertedIndex(absoluteFilePath, oldEntry.entries);
    }
    _index.remove(absoluteFilePath);
    _scheduleSave(root, parameters);
  }

  void _scheduleSave(
    String packageRoot, [
    AvoidDuplicateCodeParameters? parameters,
  ]) {
    _saveDebouncer.run(() {
      _performSave(packageRoot, parameters);
    });
  }

  void _performSave(
    String packageRoot, [
    AvoidDuplicateCodeParameters? parameters,
  ]) {
    // Filter _index for files belonging to this packageRoot
    final subset = <String, FileCacheEntry>{
      for (final MapEntry(:key, :value) in _index.entries)
        if (PathUtils.isWithinOrEqual(packageRoot, key)) key: value,
    };

    final params =
        parameters ?? _currentParams ?? AvoidDuplicateCodeParameters.empty();
    HashCacheStorage.save(packageRoot, subset, params);
  }

  /// Clears the entire index and deletes the persistent cache file.
  ///
  /// Primarily used in tests to ensure test isolation.
  void clear() {
    _saveDebouncer.cancel();
    _loadedRoots.clear();
    _index.clear();
    _hashToLocations.clear();
    HashCacheStorage.delete(Directory.current.path);
    AvoidDuplicateCodeVisitor.clearPackageRootCache();
  }
}
