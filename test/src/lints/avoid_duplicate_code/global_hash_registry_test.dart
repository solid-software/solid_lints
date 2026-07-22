import 'dart:convert';
import 'dart:io' as io;

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
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
      registry = GlobalHashRegistry.instance;
      registry.resourceProvider = memoryResourceProvider;
      registry.clear();
      registry.enablePhysicalFileCleanup = false;
    });

    tearDown(() {
      registry.clear();
      registry.resourceProvider = PhysicalResourceProvider.INSTANCE;
      registry.enablePhysicalFileCleanup = true;
    });

    test('updateFile stores entries', () {
      final entries = [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
        const HashEntry(hash: 456, lineNumber: 20, tokenCount: 3),
      ];

      registry.updateFile('file_a.dart', entries, modificationStamp: 1);

      expect(registry.fileCount, equals(1));
    });

    test('findCrossFileMatches finds duplicate in other files', () {
      final fileAEntries = [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ];
      final fileBEntries = [
        const HashEntry(hash: 123, lineNumber: 15, tokenCount: 5),
      ];

      registry.updateFile('file_a.dart', fileAEntries, modificationStamp: 1);

      final matches = registry.findCrossFileMatches(
        'file_b.dart',
        fileBEntries,
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
      final entries = [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ];

      registry.updateFile('file_a.dart', entries, modificationStamp: 1);

      final matches = registry.findCrossFileMatches('file_a.dart', entries);

      expect(matches, isEmpty);
    });

    test('updateFile replaces previous entries', () {
      final oldEntries = [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ];
      final newEntries = [
        const HashEntry(hash: 456, lineNumber: 20, tokenCount: 3),
      ];

      registry.updateFile('file_a.dart', oldEntries, modificationStamp: 1);
      registry.updateFile('file_a.dart', newEntries, modificationStamp: 2);

      expect(registry.fileCount, equals(1));

      // File B tries to match against the old hash 123, should find nothing
      final matches1 = registry.findCrossFileMatches('file_b.dart', [
        const HashEntry(hash: 123, lineNumber: 15, tokenCount: 5),
      ]);
      expect(matches1, isEmpty);

      // File B tries to match against the new hash 456, should match
      final matches2 = registry.findCrossFileMatches('file_b.dart', [
        const HashEntry(hash: 456, lineNumber: 25, tokenCount: 3),
      ]);
      expect(matches2, hasLength(1));
    });

    test('removeFile clears entries for specific file', () {
      registry.updateFile('file_a.dart', [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ], modificationStamp: 1);
      registry.updateFile('file_b.dart', [
        const HashEntry(hash: 456, lineNumber: 20, tokenCount: 5),
      ], modificationStamp: 1);

      expect(registry.fileCount, equals(2));

      registry.removeFile('file_a.dart');

      expect(registry.fileCount, equals(1));

      final matches = registry.findCrossFileMatches('file_c.dart', [
        const HashEntry(hash: 123, lineNumber: 30, tokenCount: 5),
      ]);
      expect(matches, isEmpty);
    });

    test('clear empties the registry', () {
      registry.updateFile('file_a.dart', [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ], modificationStamp: 1);
      expect(registry.fileCount, equals(1));

      registry.clear();

      expect(registry.fileCount, equals(0));
    });

    test('findCrossFileMatches groups multiple duplicate locations', () {
      registry.updateFile('file_a.dart', [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ], modificationStamp: 1);
      registry.updateFile('file_b.dart', [
        const HashEntry(hash: 123, lineNumber: 20, tokenCount: 5),
      ], modificationStamp: 1);

      final matches = registry.findCrossFileMatches('file_c.dart', [
        const HashEntry(hash: 123, lineNumber: 30, tokenCount: 5),
      ]);

      expect(matches, hasLength(1));
      expect(matches.first.duplicates, hasLength(2));
      final expectedPathA = p.normalize(
        p.join(io.Directory.current.path, 'file_a.dart'),
      );
      final expectedPathB = p.normalize(
        p.join(io.Directory.current.path, 'file_b.dart'),
      );
      expect(matches.first.duplicates[0].filePath, equals(expectedPathA));
      expect(matches.first.duplicates[1].filePath, equals(expectedPathB));
    });

    test('HashCacheStorage saves and loads index', () {
      final absoluteFilePath = p.normalize(
        p.join(io.Directory.current.path, 'file_a.dart'),
      );
      final index = {
        absoluteFilePath: const FileCacheEntry(
          modificationStamp: 123456,
          entries: [HashEntry(hash: 123, lineNumber: 10, tokenCount: 5)],
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
      expect(entry.lineNumber, equals(10));
      expect(entry.tokenCount, equals(5));

      storage.delete();
    });

    test('findCrossFileMatches cleans up absolute paths of deleted files', () {
      registry.enablePhysicalFileCleanup = true;
      final tempPath = p.normalize(
        p.join(io.Directory.systemTemp.path, 'temp_test_file.dart'),
      );
      memoryResourceProvider.newFile(tempPath, 'void main() {}');

      registry.updateFile(tempPath, [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ], modificationStamp: 1);
      expect(registry.fileCount, equals(1));

      // Delete the file from the memory resource provider
      memoryResourceProvider.deleteFile(tempPath);

      // Trigger matching, which should clean up the deleted tempPath
      // from registry
      final matches = registry.findCrossFileMatches('other_file.dart', [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ]);

      expect(matches, isEmpty);
      expect(registry.fileCount, equals(0));
    });

    test('findCrossFileMatches cleans up absolute paths of excluded files', () {
      final absoluteExcludedPath = p.normalize(
        '/workspace/project/lib/excluded.dart',
      );

      registry.updateFile(absoluteExcludedPath, [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ], modificationStamp: 1);
      expect(registry.fileCount, equals(1));

      // Trigger matching with a callback that considers absoluteExcludedPath
      // as excluded
      final matches = registry.findCrossFileMatches('other_file.dart', [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ], isFileExcluded: (path) => path == absoluteExcludedPath);

      expect(matches, isEmpty);
      expect(registry.fileCount, equals(0));
    });

    test('HashCacheStorage invalidates cache on config change', () {
      final absoluteFilePath = p.normalize(
        p.join(io.Directory.current.path, 'file.dart'),
      );
      final index = {
        absoluteFilePath: const FileCacheEntry(
          modificationStamp: 123456,
          entries: [HashEntry(hash: 123, lineNumber: 10, tokenCount: 5)],
        ),
      };

      final params1 = AvoidDuplicateCodeParameters.empty();
      final params2 = AvoidDuplicateCodeParameters(
        minTokens: 5,
        ignoreLiterals: true,
        ignoreIdentifiers: false,
        checkBlocks: true,
        exclude: params1.exclude,
      );

      final storage1 = HashCacheStorage(
        packageRoot: io.Directory.current.path,
        resourceProvider: memoryResourceProvider,
        currentParams: params1,
      );

      // Save with params1
      storage1.save(index);

      // Loading with params1 should succeed
      final loaded1 = storage1.load();
      expect(loaded1, isNotNull);

      // Loading with params2 (different config) should return null
      // (invalidated)
      final storage2 = HashCacheStorage(
        packageRoot: io.Directory.current.path,
        resourceProvider: memoryResourceProvider,
        currentParams: params2,
      );
      final loaded2 = storage2.load();
      expect(loaded2, isNull);

      storage1.delete();
    });

    test('findCrossFileMatches processes multiple candidates correctly', () {
      registry.updateFile('file_a.dart', [
        const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
      ], modificationStamp: 1);

      final matches = registry.findCrossFileMatches('file_b.dart', [
        const HashEntry(hash: 123, lineNumber: 20, tokenCount: 5), // Match
        const HashEntry(hash: 999, lineNumber: 30, tokenCount: 10), // No match
      ]);

      expect(matches, hasLength(1));
      expect(matches.first.duplicates.first.entry.hash, equals(123));
    });

    test('HashCacheStorage.load returns null when cache file is missing', () {
      final storage = HashCacheStorage(
        packageRoot: io.Directory.current.path,
        resourceProvider: memoryResourceProvider,
      );

      // Ensure any existing cache is deleted
      storage.delete();

      final loaded = storage.load();

      expect(loaded, isNull);
    });

    test('HashCacheStorage.load returns null and does not throw when cache '
        'file is corrupted', () {
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

      final loaded = storage.load();
      expect(loaded, isNull);

      storage.delete();
    });

    test('AvoidDuplicateCodeParameters value equality', () {
      final params1 = AvoidDuplicateCodeParameters(
        minTokens: 30,
        ignoreLiterals: false,
        ignoreIdentifiers: true,
        checkBlocks: true,
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
        ignoreLiterals: false,
        ignoreIdentifiers: true,
        checkBlocks: true,
        exclude: ExcludedIdentifiersListParameter(
          exclude: [
            const ExcludedIdentifierParameter(
              methodName: 'foo',
              className: 'Bar',
            ),
          ],
        ),
      );

      final paramsDifferentExclude = AvoidDuplicateCodeParameters(
        minTokens: 30,
        ignoreLiterals: false,
        ignoreIdentifiers: true,
        checkBlocks: true,
        exclude: ExcludedIdentifiersListParameter(
          exclude: [const ExcludedIdentifierParameter(methodName: 'different')],
        ),
      );

      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));

      expect(params1, isNot(equals(paramsDifferentExclude)));
    });

    test(
      'does not match or clear files from sibling directories with prefixing names',
      () {
        final currentRoot = io.Directory.current.path;
        final siblingRoot = '${currentRoot}_sibling';
        final siblingFilePath = p.normalize(p.join(siblingRoot, 'file.dart'));
        final projectFilePath = p.normalize(p.join(currentRoot, 'file.dart'));

        registry.updateFile(projectFilePath, [
          const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
        ], modificationStamp: 1);

        registry.updateFile(siblingFilePath, [
          const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
        ], modificationStamp: 1);

        expect(registry.fileCount, equals(2));

        // 1. findCrossFileMatches should not find duplicate in siblingFilePath
        // if limited to currentRoot.
        final matches = registry.findCrossFileMatches(projectFilePath, [
          const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5),
        ], packageRoot: currentRoot);
        expect(matches, isEmpty);

        // 2. clearEntriesForRoot should not clear siblingFilePath when
        // clearing currentRoot.
        final newParams = AvoidDuplicateCodeParameters(
          minTokens: 40,
          ignoreLiterals: false,
          ignoreIdentifiers: false,
          checkBlocks: true,
          exclude: AvoidDuplicateCodeParameters.empty().exclude,
        );

        registry.updateFile(
          projectFilePath,
          [const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5)],
          modificationStamp: 1,
          parameters: newParams,
          packageRoot: currentRoot,
        );

        expect(
          registry.getFileEntries(siblingFilePath, packageRoot: siblingRoot),
          isNotNull,
        );
      },
    );

    test(
      'debounces save operations independently for different package roots',
      () async {
        final tempDir1 = '/temp/package1';
        final tempDir2 = '/temp/package2';

        final file1 = p.normalize(p.join(tempDir1, 'file.dart'));
        final file2 = p.normalize(p.join(tempDir2, 'file.dart'));

        registry.updateFile(
          file1,
          [const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5)],
          modificationStamp: 1,
          packageRoot: tempDir1,
        );

        registry.updateFile(
          file2,
          [const HashEntry(hash: 456, lineNumber: 10, tokenCount: 5)],
          modificationStamp: 1,
          packageRoot: tempDir2,
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
        ignoreLiterals: false,
        ignoreIdentifiers: false,
        checkBlocks: true,
        exclude: AvoidDuplicateCodeParameters.empty().exclude,
      );

      final params2 = AvoidDuplicateCodeParameters(
        minTokens: 40,
        ignoreLiterals: false,
        ignoreIdentifiers: false,
        checkBlocks: true,
        exclude: AvoidDuplicateCodeParameters.empty().exclude,
      );

      registry.updateFile(
        file1,
        [const HashEntry(hash: 123, lineNumber: 10, tokenCount: 5)],
        modificationStamp: 1,
        parameters: params1,
        packageRoot: tempDir1,
      );

      registry.updateFile(
        file2,
        [const HashEntry(hash: 456, lineNumber: 10, tokenCount: 5)],
        modificationStamp: 1,
        parameters: params2,
        packageRoot: tempDir2,
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
}
