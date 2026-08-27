import 'dart:convert';
import 'dart:io' as io;

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/common/parameters/excluded_identifier_parameter.dart';
import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/hash_cache_storage.dart';
import 'package:test/test.dart';

void main() {
  group('GlobalHashRegistry', () {
    late GlobalHashRegistry registry;
    late MemoryResourceProvider memoryResourceProvider;

    setUp(() {
      memoryResourceProvider = MemoryResourceProvider();
      registry = GlobalHashRegistry.instance
        ..clear(resourceProvider: memoryResourceProvider)
        ..enablePhysicalFileCleanup = false;
    });

    tearDown(
      () => registry
        ..clear(resourceProvider: memoryResourceProvider)
        ..enablePhysicalFileCleanup = true,
    );

    group('in-memory file indexing and lookup', () {
      test('updateFile stores entries and increments fileCount', () {
        final entries = [
          _TestFactory.entry(hash: 123),
          _TestFactory.entry(hash: 456, lineNumber: 20, tokenCount: 3),
        ];

        registry.updateFile(
          'file_a.dart',
          entries,
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );

        expect(registry.fileCount, equals(1));
      });

      test('getFileEntries returns stored entries for a file', () {
        final entries = [
          _TestFactory.entry(hash: 123),
          _TestFactory.entry(hash: 456, lineNumber: 20),
        ];

        registry.updateFile(
          'file_a.dart',
          entries,
          modificationStamp: 42,
          resourceProvider: memoryResourceProvider,
        );

        final stored = registry.getFileEntries(
          'file_a.dart',
          resourceProvider: memoryResourceProvider,
        );
        expect(stored, isNotNull);
        expect(stored, hasLength(2));
        expect(stored!.first.hash, equals(123));
        expect(stored.last.hash, equals(456));

        expect(
          registry.getFileEntries(
            'unknown.dart',
            resourceProvider: memoryResourceProvider,
          ),
          isNull,
        );
      });

      test('getModificationStamp returns stored stamp or null', () {
        registry.updateFile(
          'file_a.dart',
          [_TestFactory.entry(hash: 123)],
          modificationStamp: 12345,
          resourceProvider: memoryResourceProvider,
        );

        expect(
          registry.getModificationStamp(
            'file_a.dart',
            resourceProvider: memoryResourceProvider,
          ),
          equals(12345),
        );
        expect(
          registry.getModificationStamp(
            'unknown.dart',
            resourceProvider: memoryResourceProvider,
          ),
          isNull,
        );
      });

      test('updateFile replaces previous entries', () {
        final oldEntries = [_TestFactory.entry(hash: 123)];
        final newEntries = [
          _TestFactory.entry(hash: 456, lineNumber: 20, tokenCount: 3),
        ];

        registry.updateFile(
          'file_a.dart',
          oldEntries,
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );
        registry.updateFile(
          'file_a.dart',
          newEntries,
          modificationStamp: 2,
          resourceProvider: memoryResourceProvider,
        );

        expect(registry.fileCount, equals(1));

        // File B tries to match against the old hash 123, should find nothing
        final matches1 = registry.findCrossFileMatches('file_b.dart', [
          _TestFactory.entry(hash: 123, lineNumber: 15),
        ], resourceProvider: memoryResourceProvider);
        expect(matches1, isEmpty);

        // File B tries to match against the new hash 456, should match
        final matches2 = registry.findCrossFileMatches('file_b.dart', [
          _TestFactory.entry(hash: 456, lineNumber: 25, tokenCount: 3),
        ], resourceProvider: memoryResourceProvider);
        expect(matches2, hasLength(1));
      });

      test('removeFile clears entries for specific file', () {
        registry.updateFile(
          'file_a.dart',
          [_TestFactory.entry(hash: 123)],
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );
        registry.updateFile(
          'file_b.dart',
          [_TestFactory.entry(hash: 456, lineNumber: 20)],
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );

        expect(registry.fileCount, equals(2));

        registry.removeFile(
          'file_a.dart',
          resourceProvider: memoryResourceProvider,
        );

        expect(registry.fileCount, equals(1));

        final matches = registry.findCrossFileMatches('file_c.dart', [
          _TestFactory.entry(hash: 123, lineNumber: 30),
        ], resourceProvider: memoryResourceProvider);
        expect(matches, isEmpty);
      });

      test('clear empties the entire registry', () {
        registry.updateFile(
          'file_a.dart',
          [_TestFactory.entry(hash: 123)],
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );
        expect(registry.fileCount, equals(1));

        registry.clear(resourceProvider: memoryResourceProvider);

        expect(registry.fileCount, equals(0));
      });

      test('clear deletes cache files for all loaded roots', () {
        final pkgRoot1 = '/workspace/pkg1';
        final pkgRoot2 = '/workspace/pkg2';

        final file1 = p.normalize(p.join(pkgRoot1, 'lib/file.dart'));
        final file2 = p.normalize(p.join(pkgRoot2, 'lib/file.dart'));

        registry.updateFile(
          file1,
          [_TestFactory.entry(hash: 123)],
          modificationStamp: 1,
          packageRoot: pkgRoot1,
          resourceProvider: memoryResourceProvider,
        );

        registry.updateFile(
          file2,
          [_TestFactory.entry(hash: 456)],
          modificationStamp: 1,
          packageRoot: pkgRoot2,
          resourceProvider: memoryResourceProvider,
        );

        HashCacheStorage(
          packageRoot: pkgRoot1,
          resourceProvider: memoryResourceProvider,
        ).save({
          file1: FileCacheEntry(
            modificationStamp: 1,
            entries: [_TestFactory.entry(hash: 123)],
          ),
        });

        HashCacheStorage(
          packageRoot: pkgRoot2,
          resourceProvider: memoryResourceProvider,
        ).save({
          file2: FileCacheEntry(
            modificationStamp: 1,
            entries: [_TestFactory.entry(hash: 456)],
          ),
        });

        final cacheFile1 = memoryResourceProvider.getFile(
          p.normalize(
            p.join(pkgRoot1, '.dart_tool/solid_lints/duplicate_index.json'),
          ),
        );
        final cacheFile2 = memoryResourceProvider.getFile(
          p.normalize(
            p.join(pkgRoot2, '.dart_tool/solid_lints/duplicate_index.json'),
          ),
        );

        expect(cacheFile1.exists, isTrue);
        expect(cacheFile2.exists, isTrue);

        registry.clear(resourceProvider: memoryResourceProvider);

        expect(registry.fileCount, equals(0));
        expect(cacheFile1.exists, isFalse);
        expect(cacheFile2.exists, isFalse);
      });

      test('findPackageRoot discovers package root from pubspec.yaml', () {
        const pkgRoot = '/workspace/my_package';
        const filePath = '$pkgRoot/lib/src/feature/file.dart';

        memoryResourceProvider.newFile('$pkgRoot/pubspec.yaml', 'name: my_pkg');

        final discovered = registry.findPackageRoot(
          filePath,
          resourceProvider: memoryResourceProvider,
        );
        expect(discovered, equals(p.normalize(pkgRoot)));

        // Returns null when no pubspec exists
        expect(
          registry.findPackageRoot(
            '/other/dir/file.dart',
            resourceProvider: memoryResourceProvider,
          ),
          isNull,
        );
        expect(
          registry.findPackageRoot(
            '',
            resourceProvider: memoryResourceProvider,
          ),
          isNull,
        );
      });
    });

    group('cross-file duplicate matching', () {
      test('findCrossFileMatches finds duplicate in other files', () {
        final fileAEntries = [_TestFactory.entry(hash: 123)];
        final fileBEntries = [_TestFactory.entry(hash: 123, lineNumber: 15)];

        registry.updateFile(
          'file_a.dart',
          fileAEntries,
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );

        final matches = registry.findCrossFileMatches(
          'file_b.dart',
          fileBEntries,
          resourceProvider: memoryResourceProvider,
        );

        expect(matches, hasLength(1));
        expect(matches.first.duplicates, hasLength(1));
        final expectedPath = p.normalize(
          p.join(io.Directory.current.path, 'file_a.dart'),
        );
        expect(matches.first.duplicates.first.filePath, equals(expectedPath));
        expect(matches.first.duplicates.first.entry.hash, equals(123));
        expect(matches.first.duplicates.first.entry.lineNumber, equals(10));
      });

      test('findCrossFileMatches ignores same file', () {
        final entries = [_TestFactory.entry(hash: 123)];

        registry.updateFile(
          'file_a.dart',
          entries,
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );

        final matches = registry.findCrossFileMatches(
          'file_a.dart',
          entries,
          resourceProvider: memoryResourceProvider,
        );

        expect(matches, isEmpty);
      });

      test('findCrossFileMatches groups multiple duplicate locations', () {
        registry.updateFile(
          'file_a.dart',
          [_TestFactory.entry(hash: 123)],
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );
        registry.updateFile(
          'file_b.dart',
          [_TestFactory.entry(hash: 123, lineNumber: 20)],
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );

        final matches = registry.findCrossFileMatches('file_c.dart', [
          _TestFactory.entry(hash: 123, lineNumber: 30),
        ], resourceProvider: memoryResourceProvider);

        expect(matches, hasLength(1));
        expect(matches.first.duplicates, hasLength(2));
        final expectedPathA = p.normalize(
          p.join(io.Directory.current.path, 'file_a.dart'),
        );
        final expectedPathB = p.normalize(
          p.join(io.Directory.current.path, 'file_b.dart'),
        );
        expect(
          matches.first.duplicates.map((d) => d.filePath),
          containsAll([expectedPathA, expectedPathB]),
        );
      });

      test('findCrossFileMatches processes multiple candidates correctly', () {
        registry.updateFile(
          'file_a.dart',
          [_TestFactory.entry(hash: 123)],
          modificationStamp: 1,
          resourceProvider: memoryResourceProvider,
        );

        final matches = registry.findCrossFileMatches('file_b.dart', [
          _TestFactory.entry(hash: 123, lineNumber: 20), // Match
          _TestFactory.entry(hash: 999, lineNumber: 30, tokenCount: 10),
        ], resourceProvider: memoryResourceProvider);

        expect(matches, hasLength(1));
        expect(matches.first.duplicates.first.entry.hash, equals(123));
      });

      test(
        'does not match or clear files from sibling directories with prefixing names',
        () {
          final currentRoot = io.Directory.current.path;
          final siblingRoot = '${currentRoot}_sibling';
          final siblingFilePath = p.normalize(p.join(siblingRoot, 'file.dart'));
          final projectFilePath = p.normalize(p.join(currentRoot, 'file.dart'));

          registry.updateFile(
            projectFilePath,
            [_TestFactory.entry(hash: 123)],
            modificationStamp: 1,
            resourceProvider: memoryResourceProvider,
          );

          registry.updateFile(
            siblingFilePath,
            [_TestFactory.entry(hash: 123)],
            modificationStamp: 1,
            resourceProvider: memoryResourceProvider,
          );

          expect(registry.fileCount, equals(2));

          // 1. findCrossFileMatches should not find duplicate in siblingFilePath
          // if limited to currentRoot.
          final matches = registry.findCrossFileMatches(
            projectFilePath,
            [_TestFactory.entry(hash: 123)],
            packageRoot: currentRoot,
            resourceProvider: memoryResourceProvider,
          );
          expect(matches, isEmpty);

          // 2. clearEntriesForRoot should not clear siblingFilePath when
          // clearing currentRoot.
          final newParams = AvoidDuplicateCodeParameters(
            minTokens: 40,
            exclude: AvoidDuplicateCodeParameters.empty().exclude,
          );

          registry.updateFile(
            projectFilePath,
            [_TestFactory.entry(hash: 123)],
            modificationStamp: 1,
            parameters: newParams,
            packageRoot: currentRoot,
            resourceProvider: memoryResourceProvider,
          );

          expect(
            registry.getFileEntries(
              siblingFilePath,
              packageRoot: siblingRoot,
              resourceProvider: memoryResourceProvider,
            ),
            isNotNull,
          );
        },
      );
    });

    group('stale entry cleanup', () {
      test(
        'findCrossFileMatches cleans up absolute paths of deleted files',
        () {
          registry.enablePhysicalFileCleanup = true;
          final tempPath = p.normalize(
            p.join(io.Directory.systemTemp.path, 'temp_test_file.dart'),
          );
          memoryResourceProvider.newFile(tempPath, 'void main() {}');

          registry.updateFile(
            tempPath,
            [_TestFactory.entry(hash: 123)],
            modificationStamp: 1,
            resourceProvider: memoryResourceProvider,
          );
          expect(registry.fileCount, equals(1));

          // Delete the file from the memory resource provider
          memoryResourceProvider.deleteFile(tempPath);

          // Trigger matching, which should clean up the deleted tempPath
          // from registry
          final matches = registry.findCrossFileMatches('other_file.dart', [
            _TestFactory.entry(hash: 123),
          ], resourceProvider: memoryResourceProvider);

          expect(matches, isEmpty);
          expect(registry.fileCount, equals(0));
        },
      );

      test(
        'findCrossFileMatches cleans up absolute paths of excluded files',
        () {
          final absoluteExcludedPath = p.normalize(
            '/workspace/project/lib/excluded.dart',
          );

          registry.updateFile(
            absoluteExcludedPath,
            [_TestFactory.entry(hash: 123)],
            modificationStamp: 1,
            resourceProvider: memoryResourceProvider,
          );
          expect(registry.fileCount, equals(1));

          // Trigger matching with a callback that considers absoluteExcludedPath
          // as excluded
          final matches = registry.findCrossFileMatches(
            'other_file.dart',
            [_TestFactory.entry(hash: 123)],
            isFileExcluded: (path) => path == absoluteExcludedPath,
            resourceProvider: memoryResourceProvider,
          );

          expect(matches, isEmpty);
          expect(registry.fileCount, equals(0));
        },
      );
    });

    group('multi-package workspaces and debounced persistence', () {
      test(
        'debounces save operations independently for different package roots',
        () async {
          final tempDir1 = '/temp/package1';
          final tempDir2 = '/temp/package2';

          final file1 = p.normalize(p.join(tempDir1, 'file.dart'));
          final file2 = p.normalize(p.join(tempDir2, 'file.dart'));

          registry.updateFile(
            file1,
            [_TestFactory.entry(hash: 123)],
            modificationStamp: 1,
            packageRoot: tempDir1,
            resourceProvider: memoryResourceProvider,
          );

          registry.updateFile(
            file2,
            [_TestFactory.entry(hash: 456)],
            modificationStamp: 1,
            packageRoot: tempDir2,
            resourceProvider: memoryResourceProvider,
          );

          // Wait for debounce duration (500ms + some buffer)
          await Future<void>.delayed(const Duration(milliseconds: 600));

          // Both caches should be saved on disk
          final loaded1 = HashCacheStorage(
            packageRoot: tempDir1,
            resourceProvider: memoryResourceProvider,
          ).load();
          final loaded2 = HashCacheStorage(
            packageRoot: tempDir2,
            resourceProvider: memoryResourceProvider,
          ).load();

          expect(loaded1, isNotNull);
          expect(loaded1!.keys.first, equals(file1));

          expect(loaded2, isNotNull);
          expect(loaded2!.keys.first, equals(file2));
        },
      );

      test('uses correct package-specific parameters during debounced save '
          'in multi-package workspace', () async {
        final tempDir1 = '/temp/package1';
        final tempDir2 = '/temp/package2';

        final file1 = p.normalize(p.join(tempDir1, 'file.dart'));
        final file2 = p.normalize(p.join(tempDir2, 'file.dart'));

        final params1 = AvoidDuplicateCodeParameters(
          minTokens: 30,
          exclude: AvoidDuplicateCodeParameters.empty().exclude,
        );

        final params2 = AvoidDuplicateCodeParameters(
          minTokens: 40,
          exclude: AvoidDuplicateCodeParameters.empty().exclude,
        );

        registry.updateFile(
          file1,
          [_TestFactory.entry(hash: 123)],
          modificationStamp: 1,
          parameters: params1,
          packageRoot: tempDir1,
          resourceProvider: memoryResourceProvider,
        );

        registry.updateFile(
          file2,
          [_TestFactory.entry(hash: 456)],
          modificationStamp: 1,
          parameters: params2,
          packageRoot: tempDir2,
          resourceProvider: memoryResourceProvider,
        );

        // Wait for debounce duration (500ms + some buffer)
        await Future<void>.delayed(const Duration(milliseconds: 600));

        final cachePath1 = p.normalize(
          p.join(tempDir1, '.dart_tool/solid_lints/duplicate_index.json'),
        );
        final cachePath2 = p.normalize(
          p.join(tempDir2, '.dart_tool/solid_lints/duplicate_index.json'),
        );

        final cacheFile1 = memoryResourceProvider.getFile(cachePath1);
        final cacheFile2 = memoryResourceProvider.getFile(cachePath2);

        expect(cacheFile1.exists, isTrue);
        expect(cacheFile2.exists, isTrue);

        final content1 =
            jsonDecode(cacheFile1.readAsStringSync()) as Map<String, dynamic>;
        final content2 =
            jsonDecode(cacheFile2.readAsStringSync()) as Map<String, dynamic>;

        expect(content1['config']?['min_tokens'], equals(30));
        expect(content2['config']?['min_tokens'], equals(40));
      });
    });

    group('HashCacheStorage', () {
      test('saves and loads index correctly', () {
        final absoluteFilePath = p.normalize(
          p.join(io.Directory.current.path, 'file_a.dart'),
        );
        final index = {
          absoluteFilePath: FileCacheEntry(
            modificationStamp: 123456,
            entries: [_TestFactory.entry(hash: 123)],
          ),
        };

        final storage = HashCacheStorage(
          packageRoot: io.Directory.current.path,
          resourceProvider: memoryResourceProvider,
        );

        storage.save(index);

        final loaded = storage.load();
        expect(loaded, isNotNull);
        expect(loaded!.length, equals(1));
        expect(loaded[absoluteFilePath]!.entries, hasLength(1));
        expect(loaded[absoluteFilePath]!.modificationStamp, equals(123456));

        final entry = loaded[absoluteFilePath]!.entries.first;
        expect(entry.hash, equals(123));
        expect(entry.exactHash, equals(123));
        expect(entry.lineNumber, equals(10));
        expect(entry.offset, equals(0));
        expect(entry.length, equals(0));
        expect(entry.tokenCount, equals(5));
      });

      test('invalidates cache on config change', () {
        final absoluteFilePath = p.normalize(
          p.join(io.Directory.current.path, 'file.dart'),
        );
        final index = {
          absoluteFilePath: FileCacheEntry(
            modificationStamp: 123456,
            entries: [_TestFactory.entry(hash: 123)],
          ),
        };

        final params1 = AvoidDuplicateCodeParameters.empty();
        final params2 = AvoidDuplicateCodeParameters(
          minTokens: 5,
          exclude: params1.exclude,
        );

        final storage1 = HashCacheStorage(
          packageRoot: io.Directory.current.path,
          resourceProvider: memoryResourceProvider,
          currentParams: params1,
        );

        storage1.save(index);

        // Loading with params1 should succeed
        final loaded1 = storage1.load();
        expect(loaded1, isNotNull);

        // Loading with params2 (different config) should return null (invalidated)
        final storage2 = HashCacheStorage(
          packageRoot: io.Directory.current.path,
          resourceProvider: memoryResourceProvider,
          currentParams: params2,
        );
        final loaded2 = storage2.load();
        expect(loaded2, isNull);
      });

      test('load returns null when cache file is missing', () {
        final storage = HashCacheStorage(
          packageRoot: io.Directory.current.path,
          resourceProvider: memoryResourceProvider,
        );

        expect(storage.load(), isNull);
      });

      test(
        'load returns null and does not throw when cache file is corrupted',
        () {
          final storage = HashCacheStorage(
            packageRoot: io.Directory.current.path,
            resourceProvider: memoryResourceProvider,
          );

          final cachePath = p.normalize(
            p.join(
              io.Directory.current.path,
              '.dart_tool',
              'solid_lints',
              'duplicate_index.json',
            ),
          );
          memoryResourceProvider.newFile(
            cachePath,
            '["invalid", "json", "structure", "not", "a", "map"]',
          );

          expect(storage.load(), isNull);
        },
      );
    });

    group('HashEntry', () {
      test('serialization preserves exactHash', () {
        final entry = _TestFactory.entry(
          hash: 100,
          exactHash: 200,
          lineNumber: 15,
          offset: 50,
          length: 80,
          tokenCount: 25,
        );

        final json = entry.toJson();
        expect(json['h'], equals(100));
        expect(json['e'], equals(200));

        final restored = HashEntry.fromJson(json);
        expect(restored.hash, equals(100));
        expect(restored.exactHash, equals(200));
        expect(restored.lineNumber, equals(15));
        expect(restored.offset, equals(50));
        expect(restored.length, equals(80));
        expect(restored.tokenCount, equals(25));
      });
    });

    group('AvoidDuplicateCodeParameters', () {
      test('supports value equality and hashCode', () {
        final params1 = AvoidDuplicateCodeParameters(
          minTokens: 30,
          exclude: ExcludedIdentifiersListParameter(
            exclude: [
              const ExcludedIdentifierParameter(
                methodName: 'foo',
                className: 'Bar',
              ),
            ],
          ),
        );

        final params2 = AvoidDuplicateCodeParameters(
          minTokens: 30,
          exclude: ExcludedIdentifiersListParameter(
            exclude: [
              const ExcludedIdentifierParameter(
                methodName: 'foo',
                className: 'Bar',
              ),
            ],
          ),
        );

        final paramsDifferent = AvoidDuplicateCodeParameters(
          minTokens: 30,
          exclude: ExcludedIdentifiersListParameter(
            exclude: [
              const ExcludedIdentifierParameter(methodName: 'different'),
            ],
          ),
        );

        expect(params1, equals(params2));
        expect(params1.hashCode, equals(params2.hashCode));
        expect(params1, isNot(equals(paramsDifferent)));
      });
    });
  });
}

abstract final class _TestFactory {
  static HashEntry entry({
    required int hash,
    int? exactHash,
    int lineNumber = 10,
    int offset = 0,
    int length = 0,
    int tokenCount = 5,
  }) => HashEntry(
    hash: hash,
    exactHash: exactHash ?? hash,
    lineNumber: lineNumber,
    offset: offset,
    length: length,
    tokenCount: tokenCount,
  );
}
