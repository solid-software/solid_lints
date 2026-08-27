import 'package:solid_lints/src/lints/avoid_duplicate_code/models/cross_file_match.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:test/test.dart';

void main() {
  group('CrossFileMatchIterableExtension', () {
    test('toDuplicatesByHash groups matches by entry hash', () {
      final locA = DuplicateLocation(
        filePath: 'lib/a.dart',
        entry: _TestFactory.entry(hash: 100, offset: 10),
      );
      final locB = DuplicateLocation(
        filePath: 'lib/b.dart',
        entry: _TestFactory.entry(hash: 200, offset: 20),
      );
      final match1 = CrossFileMatch(
        currentEntry: _TestFactory.entry(hash: 100, offset: 0),
        duplicates: {locA},
      );
      final match2 = CrossFileMatch(
        currentEntry: _TestFactory.entry(hash: 200, offset: 50),
        duplicates: {locB},
      );

      final result = [match1, match2].toDuplicatesByHash();

      expect(
        result,
        equals({
          100: {locA},
          200: {locB},
        }),
      );
    });

    test(
      'toDuplicatesByHash aggregates duplicates when matches share same hash',
      () {
        final locA = DuplicateLocation(
          filePath: 'lib/a.dart',
          entry: _TestFactory.entry(hash: 100, offset: 10),
        );
        final locB = DuplicateLocation(
          filePath: 'lib/b.dart',
          entry: _TestFactory.entry(hash: 100, offset: 20),
        );
        final match1 = CrossFileMatch(
          currentEntry: _TestFactory.entry(hash: 100, offset: 0),
          duplicates: {locA},
        );
        final match2 = CrossFileMatch(
          currentEntry: _TestFactory.entry(hash: 100, offset: 100),
          duplicates: {locB},
        );

        final result = [match1, match2].toDuplicatesByHash();

        expect(
          result,
          equals({
            100: {locA, locB},
          }),
        );
      },
    );

    test('toDuplicatesByHash deduplicates identical duplicate locations', () {
      final loc = DuplicateLocation(
        filePath: 'lib/a.dart',
        entry: _TestFactory.entry(hash: 100, offset: 10),
      );
      final match1 = CrossFileMatch(
        currentEntry: _TestFactory.entry(hash: 100, offset: 0),
        duplicates: {loc},
      );
      final match2 = CrossFileMatch(
        currentEntry: _TestFactory.entry(hash: 100, offset: 50),
        duplicates: {loc},
      );

      final result = [match1, match2].toDuplicatesByHash();

      expect(
        result,
        equals({
          100: {loc},
        }),
      );
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
