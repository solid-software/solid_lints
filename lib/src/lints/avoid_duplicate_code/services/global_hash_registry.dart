import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:collection/collection.dart';

import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/cross_file_match.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/hash_cache_storage.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/debouncer.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/hash_entry_list_extension.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/path_utils.dart';
import 'package:solid_lints/src/utils/iterable_utils.dart';
import 'package:solid_lints/src/utils/set_dictionary.dart';

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
  final _hashToLocations = SetDictionary<int, DuplicateLocation>();

  final _loadedRoots = <String, AvoidDuplicateCodeParameters>{};
  final _saveDebouncers = <String, Debouncer>{};
  final _packageRootCache = <String, String?>{};

  GlobalHashRegistry._();

  /// The number of files currently indexed.
  int get fileCount => _index.length;

  String _getRoot(String? packageRoot) =>
      packageRoot ?? io.Directory.current.path;

  void _addToInvertedIndex(
    String absoluteFilePath,
    List<HashEntry> entries,
  ) => _hashToLocations.addAll(entries.asIndexEntries(absoluteFilePath));

  void _removeFromInvertedIndex(
    String absoluteFilePath,
    List<HashEntry> entries,
  ) => _hashToLocations.removeAll(entries.asIndexEntries(absoluteFilePath));

  void _ensureLoaded(
    String packageRoot,
    ResourceProvider resourceProvider, [
    AvoidDuplicateCodeParameters? currentParams,
  ]) {
    if (currentParams == null && _loadedRoots.containsKey(packageRoot)) {
      return;
    }

    final params = currentParams ?? AvoidDuplicateCodeParameters.empty();
    if (_loadedRoots[packageRoot] case final previousParams?) {
      if (previousParams == params) return;

      _clearEntriesForRoot(packageRoot);
    }

    _loadedRoots[packageRoot] = params;

    final cached = HashCacheStorage(
      packageRoot: packageRoot,
      resourceProvider: resourceProvider,
      currentParams: params,
    ).load();
    if (cached == null) return;

    final deletedFiles = !enablePhysicalFileCleanup
        ? <String>{}
        : cached.keys.where((p) => !resourceProvider.getFile(p).exists).toSet();

    final hashes = cached.keys.toSet().difference(deletedFiles);

    for (final k in hashes) {
      _index[k] = cached[k]!;
      _addToInvertedIndex(k, cached[k]!.entries);
    }

    if (deletedFiles.isNotEmpty) {
      _scheduleSave(packageRoot, resourceProvider);
    }
  }

  void _clearEntriesForRoot(String packageRoot) {
    _index.removeWhere((key, oldEntry) {
      if (PathUtils.isWithinOrEqual(packageRoot, key)) {
        _removeFromInvertedIndex(key, oldEntry.entries);
        return true;
      }
      return false;
    });
  }

  String _resolveAndLoad(
    String filePath,
    String? packageRoot,
    ResourceProvider resourceProvider,
    AvoidDuplicateCodeParameters? parameters,
  ) {
    final root = _getRoot(packageRoot);
    _ensureLoaded(root, resourceProvider, parameters);
    return PathUtils.normalizePath(filePath, root);
  }

  /// Returns the cached modification stamp for [filePath], or `null` if not
  /// indexed.
  int? getModificationStamp(
    String filePath, {
    required ResourceProvider resourceProvider,
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) => _getCache(
    filePath,
    packageRoot,
    parameters,
    resourceProvider,
  )?.modificationStamp;

  /// Returns the cached entries for [filePath], or `null` if not indexed.
  List<HashEntry>? getFileEntries(
    String filePath, {
    required ResourceProvider resourceProvider,
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) => _getCache(
    filePath,
    packageRoot,
    parameters,
    resourceProvider,
  )?.entries;

  FileCacheEntry? _getCache(
    String filePath,
    String? packageRoot,
    AvoidDuplicateCodeParameters? parameters,
    ResourceProvider resourceProvider,
  ) =>
      _index[_resolveAndLoad(
        filePath,
        packageRoot,
        resourceProvider,
        parameters,
      )];

  /// Updates the hash entries for [filePath], replacing any previous entries.
  void updateFile(
    String filePath,
    List<HashEntry> entries, {
    required int modificationStamp,
    required ResourceProvider resourceProvider,
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) {
    if (entries.isEmpty) {
      removeFile(
        filePath,
        resourceProvider: resourceProvider,
        parameters: parameters,
        packageRoot: packageRoot,
      );
      return;
    }

    final root = _getRoot(packageRoot);
    final absoluteFilePath = _resolveAndLoad(
      filePath,
      packageRoot,
      resourceProvider,
      parameters,
    );

    if (_index[absoluteFilePath] case final oldEntry?) {
      _removeFromInvertedIndex(absoluteFilePath, oldEntry.entries);
    }

    _index[absoluteFilePath] = FileCacheEntry(
      modificationStamp: modificationStamp,
      entries: entries,
    );
    _addToInvertedIndex(absoluteFilePath, entries);
    _scheduleSave(root, resourceProvider);
  }

  /// Finds cross-file duplicates for [currentEntries] against all other
  /// indexed files (excluding [currentFilePath]).
  ///
  /// Returns a list of [CrossFileMatch] objects, one for each duplicate found.
  List<CrossFileMatch> findCrossFileMatches(
    String currentFilePath,
    List<HashEntry> currentEntries, {
    required ResourceProvider resourceProvider,
    AvoidDuplicateCodeParameters? parameters,
    bool Function(String filePath)? isFileExcluded,
    String? packageRoot,
  }) {
    final root = _getRoot(packageRoot);
    final absoluteCurrentFilePath = _resolveAndLoad(
      currentFilePath,
      packageRoot,
      resourceProvider,
      parameters,
    );

    final matches = <CrossFileMatch>[];
    final filesToRemove = <String>{};
    final fileStatusCache = <String, bool>{};

    for (final entry in currentEntries) {
      final duplicates = <DuplicateLocation>[];
      final locations = _hashToLocations[entry.hash];

      if (locations == null) continue;

      for (final loc in locations) {
        final key = loc.filePath;
        if (key == absoluteCurrentFilePath) continue;

        final isInvalid = fileStatusCache.putIfAbsent(
          key,
          () =>
              (enablePhysicalFileCleanup &&
                  !resourceProvider.getFile(key).exists) ||
              (isFileExcluded?.call(key) ?? false),
        );

        if (isInvalid) {
          filesToRemove.add(key);
        } else if (PathUtils.isWithinOrEqual(root, key) &&
            // guard against hash collisions
            loc.entry.tokenCount == entry.tokenCount) {
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

    if (filesToRemove.isEmpty) return matches;

    for (final file in filesToRemove) {
      if (_index.remove(file) case final oldEntry?) {
        _removeFromInvertedIndex(file, oldEntry.entries);
      }
    }

    _scheduleSave(root, resourceProvider);

    return matches;
  }

  /// Removes [filePath] from the index.
  void removeFile(
    String filePath, {
    required ResourceProvider resourceProvider,
    AvoidDuplicateCodeParameters? parameters,
    String? packageRoot,
  }) {
    final root = _getRoot(packageRoot);
    final absoluteFilePath = _resolveAndLoad(
      filePath,
      packageRoot,
      resourceProvider,
      parameters,
    );
    if (_index.remove(absoluteFilePath) case final oldEntry?) {
      _removeFromInvertedIndex(absoluteFilePath, oldEntry.entries);
    }
    _scheduleSave(root, resourceProvider);
  }

  void _scheduleSave(
    String packageRoot,
    ResourceProvider resourceProvider,
  ) {
    _saveDebouncers
        .putIfAbsent(packageRoot, () => Debouncer(_saveDebounceDuration))
        .run(() {
          _performSave(packageRoot, resourceProvider);
        });
  }

  void _performSave(
    String packageRoot,
    ResourceProvider resourceProvider,
  ) =>
      HashCacheStorage(
        packageRoot: packageRoot,
        resourceProvider: resourceProvider,
        currentParams:
            _loadedRoots[packageRoot] ?? AvoidDuplicateCodeParameters.empty(),
      ).save(
        // Filter _index for files belonging to this packageRoot
        _index.entries.whereKey(
          (k) => PathUtils.isWithinOrEqual(packageRoot, k),
        ),
      );

  /// Finds the package root directory containing `pubspec.yaml` for [filePath].
  String? findPackageRoot(
    String filePath, {
    required ResourceProvider resourceProvider,
  }) {
    if (filePath.isEmpty) return null;
    final dirPath = resourceProvider.pathContext.dirname(filePath);
    return _packageRootCache.putIfAbsent(
      dirPath,
      () => resourceProvider
          .getFolder(dirPath)
          .withAncestors
          .firstWhereOrNull(
            (dir) => dir.getFile('pubspec.yaml').exists,
          )
          ?.path,
    );
  }

  /// Clears the entire index and deletes the persistent cache file.
  ///
  /// Primarily used in tests to ensure test isolation.
  void clear({required ResourceProvider resourceProvider}) {
    for (final debouncer in _saveDebouncers.values) {
      debouncer.cancel();
    }
    _saveDebouncers.clear();

    for (final root in {..._loadedRoots.keys, io.Directory.current.path}) {
      HashCacheStorage(
        packageRoot: root,
        resourceProvider: resourceProvider,
      ).delete();
    }

    _loadedRoots.clear();
    _index.clear();
    _hashToLocations.clear();
    _packageRootCache.clear();
  }
}
