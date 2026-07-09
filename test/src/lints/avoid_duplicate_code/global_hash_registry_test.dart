import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/file_cache_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/global_hash_registry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/hash_cache_storage.dart';
import 'package:test/test.dart';

void main() {
  group('GlobalHashRegistry', () {
    late GlobalHashRegistry registry;

    setUp(() {
      registry = GlobalHashRegistry.instance;
      registry.clear();
      registry.enablePhysicalFileCleanup = false;
    });

    tearDown(() {
      registry.clear();
      registry.enablePhysicalFileCleanup = true;
    });

    test('updateFile stores entries', () {
      final entries = [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
        const HashEntry(hash: 456, lineNumber: 20, statementCount: 3),
      ];

      registry.updateFile('file_a.dart', entries, modificationStamp: 1);

      expect(registry.fileCount, equals(1));
    });

    test('findCrossFileMatches finds duplicate in other files', () {
      final fileAEntries = [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ];
      final fileBEntries = [
        const HashEntry(hash: 123, lineNumber: 15, statementCount: 5),
      ];

      registry.updateFile('file_a.dart', fileAEntries, modificationStamp: 1);

      final matches = registry.findCrossFileMatches('file_b.dart', fileBEntries);

      expect(matches, hasLength(1));
      expect(matches.first.duplicates, hasLength(1));
      final expectedPath = p.normalize(p.join(Directory.current.path, 'file_a.dart'));
      expect(matches.first.duplicates.first.filePath, equals(expectedPath));
      expect(matches.first.duplicates.first.entry.hash, equals(123));
      expect(matches.first.duplicates.first.entry.lineNumber, equals(10));
    });

    test('findCrossFileMatches ignores same file', () {
      final entries = [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ];

      registry.updateFile('file_a.dart', entries, modificationStamp: 1);

      final matches = registry.findCrossFileMatches('file_a.dart', entries);

      expect(matches, isEmpty);
    });

    test('updateFile replaces previous entries', () {
      final oldEntries = [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ];
      final newEntries = [
        const HashEntry(hash: 456, lineNumber: 20, statementCount: 3),
      ];

      registry.updateFile('file_a.dart', oldEntries, modificationStamp: 1);
      registry.updateFile('file_a.dart', newEntries, modificationStamp: 2);

      expect(registry.fileCount, equals(1));

      // File B tries to match against the old hash 123, should find nothing
      final matches1 = registry.findCrossFileMatches('file_b.dart', [
        const HashEntry(hash: 123, lineNumber: 15, statementCount: 5),
      ]);
      expect(matches1, isEmpty);

      // File B tries to match against the new hash 456, should match
      final matches2 = registry.findCrossFileMatches('file_b.dart', [
        const HashEntry(hash: 456, lineNumber: 25, statementCount: 3),
      ]);
      expect(matches2, hasLength(1));
    });

    test('removeFile clears entries for specific file', () {
      registry.updateFile('file_a.dart', [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ], modificationStamp: 1);
      registry.updateFile('file_b.dart', [
        const HashEntry(hash: 456, lineNumber: 20, statementCount: 5),
      ], modificationStamp: 1);

      expect(registry.fileCount, equals(2));

      registry.removeFile('file_a.dart');

      expect(registry.fileCount, equals(1));

      final matches = registry.findCrossFileMatches('file_c.dart', [
        const HashEntry(hash: 123, lineNumber: 30, statementCount: 5),
      ]);
      expect(matches, isEmpty);
    });

    test('clear empties the registry', () {
      registry.updateFile('file_a.dart', [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ], modificationStamp: 1);
      expect(registry.fileCount, equals(1));

      registry.clear();

      expect(registry.fileCount, equals(0));
    });

    test('findCrossFileMatches groups multiple duplicate locations', () {
      registry.updateFile('file_a.dart', [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ], modificationStamp: 1);
      registry.updateFile('file_b.dart', [
        const HashEntry(hash: 123, lineNumber: 20, statementCount: 5),
      ], modificationStamp: 1);

      final matches = registry.findCrossFileMatches('file_c.dart', [
        const HashEntry(hash: 123, lineNumber: 30, statementCount: 5),
      ]);

      expect(matches, hasLength(1));
      expect(matches.first.duplicates, hasLength(2));
      final expectedPathA = p.normalize(p.join(Directory.current.path, 'file_a.dart'));
      final expectedPathB = p.normalize(p.join(Directory.current.path, 'file_b.dart'));
      expect(matches.first.duplicates[0].filePath, equals(expectedPathA));
      expect(matches.first.duplicates[1].filePath, equals(expectedPathB));
    });

    test('HashCacheStorage saves and loads index', () {
      final absoluteFilePath = p.normalize(p.join(Directory.current.path, 'file_a.dart'));
      final index = {
        absoluteFilePath: const FileCacheEntry(
          modificationStamp: 123456,
          entries: [
            HashEntry(
              hash: 123,
              lineNumber: 10,
              statementCount: 5,
            ),
          ],
        ),
      };

      HashCacheStorage.save(Directory.current.path, index);

      final loaded = HashCacheStorage.load(Directory.current.path);
      expect(loaded, isNotNull);
      expect(loaded!.length, equals(1));
      expect(loaded[absoluteFilePath]!.entries, hasLength(1));
      expect(loaded[absoluteFilePath]!.modificationStamp, equals(123456));

      final entry = loaded[absoluteFilePath]!.entries.first;
      expect(entry.hash, equals(123));
      expect(entry.lineNumber, equals(10));
      expect(entry.statementCount, equals(5));

      HashCacheStorage.delete(Directory.current.path);
    });

    test('findCrossFileMatches cleans up absolute paths of deleted files', () {
      registry.enablePhysicalFileCleanup = true;
      final tempFile = File('${Directory.systemTemp.path}/temp_test_file.dart');
      tempFile.writeAsStringSync('void main() {}');

      registry.updateFile(tempFile.path, [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ], modificationStamp: 1);
      expect(registry.fileCount, equals(1));

      // Delete the file physically
      tempFile.deleteSync();

      // Trigger matching, which should clean up the deleted tempFile from registry
      final matches = registry.findCrossFileMatches('other_file.dart', [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ]);

      expect(matches, isEmpty);
      expect(registry.fileCount, equals(0));
    });

    test('findCrossFileMatches cleans up absolute paths of excluded files', () {
      final absoluteExcludedPath =
          p.normalize('/workspace/project/lib/excluded.dart');

      registry.updateFile(absoluteExcludedPath, [
        const HashEntry(hash: 123, lineNumber: 10, statementCount: 5),
      ], modificationStamp: 1);
      expect(registry.fileCount, equals(1));

      // Trigger matching with a callback that considers absoluteExcludedPath as excluded
      final matches = registry.findCrossFileMatches(
        'other_file.dart',
        [const HashEntry(hash: 123, lineNumber: 10, statementCount: 5)],
        isFileExcluded: (path) => path == absoluteExcludedPath,
      );

      expect(matches, isEmpty);
      expect(registry.fileCount, equals(0));
    });
  });
}
