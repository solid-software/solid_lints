import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/literal_info.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/services/differing_literals_analyzer.dart';
import 'package:test/test.dart';

void main() {
  group('DifferingLiteralsAnalyzer', () {
    late MemoryResourceProvider resourceProvider;
    late DifferingLiteralsAnalyzer analyzer;

    setUp(() {
      resourceProvider = MemoryResourceProvider();
      analyzer = DifferingLiteralsAnalyzer(resourceProvider: resourceProvider);
    });

    group('computeLiteralsSummary', () {
      group('validation and empty inputs', () {
        test('returns empty string when currentLiterals is empty', () {
          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: [],
              partnerLiteralsList: [
                _TestFactory.literals(['1', '2']),
              ],
            ),
            isEmpty,
          );
        });

        test('returns empty string when partnerLiteralsList is empty', () {
          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: _TestFactory.literals(['1', '2']),
              partnerLiteralsList: [],
            ),
            isEmpty,
          );
        });
      });

      group('formatting and truncation', () {
        test('returns empty string when literals are identical', () {
          final current = _TestFactory.literals(['1', "'a'"]);
          final partner = _TestFactory.literals(['1', "'a'"]);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partner],
            ),
            isEmpty,
          );
        });

        test('formats single differing literal slot', () {
          final current = _TestFactory.literals(['1']);
          final partner = _TestFactory.literals(['2']);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partner],
            ),
            equals(': [1, 2]'),
          );
        });

        test('deduplicates identical values from partners in slot', () {
          final current = _TestFactory.literals(["'foo'"]);
          final partner1 = _TestFactory.literals(["'bar'"]);
          final partner2 = _TestFactory.literals(["'bar'"]);
          final partner3 = _TestFactory.literals(["'baz'"]);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partner1, partner2, partner3],
            ),
            equals(": ['foo', 'bar', 'baz']"),
          );
        });

        test('filters out identical slots and formats only differing ones', () {
          final current = _TestFactory.literals(['1', "'same'", '10']);
          final partner = _TestFactory.literals(['2', "'same'", '20']);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partner],
            ),
            equals(': [1, 2], [10, 20]'),
          );
        });

        test('formats multiple differing literal slots up to limit', () {
          final current = _TestFactory.literals(['1', '10', "'hello'"]);
          final partner = _TestFactory.literals(['2', '20', "'foo'"]);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partner],
            ),
            equals(": [1, 2], [10, 20], ['hello', 'foo']"),
          );
        });

        test('handles partners with fewer literals gracefully', () {
          final current = _TestFactory.literals(['1', '10']);
          final partnerWithFewer = _TestFactory.literals(['2']);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partnerWithFewer],
            ),
            equals(': [1, 2]'),
          );
        });

        test('truncates slots when exceeding max displayed slots limit', () {
          final current = _TestFactory.literals([
            '1',
            '10',
            "'hello'",
            "'world'",
          ]);
          final partner = _TestFactory.literals(['2', '20', "'foo'", "'bar'"]);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partner],
            ),
            equals(": [1, 2], [10, 20], ['hello', 'foo'] (+1 more)"),
          );
        });

        test('truncates values within slot when exceeding limit', () {
          final current = _TestFactory.literals(['1']);
          final partner1 = _TestFactory.literals(['2']);
          final partner2 = _TestFactory.literals(['3']);
          final partner3 = _TestFactory.literals(['4']);

          expect(
            analyzer.computeLiteralsSummary(
              currentLiterals: current,
              partnerLiteralsList: [partner1, partner2, partner3],
            ),
            equals(': [1, 2, 3, +1 more]'),
          );
        });
      });
    });

    group('loadExternalLiterals', () {
      group('extraction', () {
        test('extracts literals when snippet is at non-zero offset', () {
          const filePath = '/test/lib/sample_offset.dart';
          const fileContent = '// comment\nvoid foo() => 123;';
          resourceProvider.newFile(filePath, fileContent);

          final location = _TestFactory.location(
            filePath,
            offset: 22,
            length: 6,
          );

          final lits = analyzer.loadExternalLiterals(location);

          expect(lits, isNotNull);
          expect(lits!.map((l) => l.text), equals(['123']));
        });
      });

      group('validation and error handling', () {
        test('returns null if file does not exist', () {
          final location = _TestFactory.location(
            '/non/existent.dart',
            length: 10,
          );

          final lits = analyzer.loadExternalLiterals(location);

          expect(lits, isNull);
        });

        test('returns null if file content is empty', () {
          const filePath = '/test/lib/sample_empty.dart';
          resourceProvider.newFile(filePath, '');

          final location = _TestFactory.location(filePath, length: 0);

          final lits = analyzer.loadExternalLiterals(location);

          expect(lits, isNull);
        });

        test('returns null for zero or negative length', () {
          const filePath = '/test/lib/sample_zero.dart';
          resourceProvider.newFile(filePath, 'void foo() {}');

          final location = _TestFactory.location(filePath);

          final lits = analyzer.loadExternalLiterals(location);

          expect(lits, isNull);
        });

        test('returns null when offset is negative', () {
          const filePath = '/test/lib/sample_neg.dart';
          resourceProvider.newFile(filePath, 'void foo() => 1;');

          final location = _TestFactory.location(
            filePath,
            offset: -1,
            length: 5,
          );

          final lits = analyzer.loadExternalLiterals(location);

          expect(lits, isNull);
        });

        test(
          'returns null when offset + length exceeds file content length',
          () {
            const filePath = '/test/lib/sample_overflow.dart';
            resourceProvider.newFile(filePath, 'void foo() => 1;');

            final location = _TestFactory.location(
              filePath,
              offset: 10,
              length: 100,
            );

            final lits = analyzer.loadExternalLiterals(location);

            expect(lits, isNull);
          },
        );
      });

      group('caching', () {
        test('caches file content across multiple calls for same file', () {
          const filePath = '/test/lib/sample_cached.dart';
          const fileContent = 'void foo() => 42;';
          resourceProvider.newFile(filePath, fileContent);

          final location = _TestFactory.location(
            filePath,
            offset: 0,
            length: fileContent.length,
          );

          final first = analyzer.loadExternalLiterals(location);
          expect(first, isNotNull);

          // Delete file from resource provider; cache should serve the content.
          resourceProvider.deleteFile(filePath);

          final second = analyzer.loadExternalLiterals(location);
          expect(second, isNotNull);
          expect(second!.map((l) => l.text), equals(['42']));
        });
      });

      group('body prefixes and snippet wrapping', () {
        for (final (label, snippet, expected) in [
          (
            'block body with {',
            '{\n  final x = 42;\n  print("hi");\n}',
            ['42', '"hi"'],
          ),
          (
            'async block body with async {',
            'async {\n  final x = 42;\n  print("hi");\n}',
            ['42', '"hi"'],
          ),
          (
            'async* block body with async* {',
            'async* {\n  final x = 42;\n  yield "hi";\n}',
            ['42', '"hi"'],
          ),
          (
            'sync* block body with sync* {',
            'sync* {\n  final x = 42;\n  yield "hi";\n}',
            ['42', '"hi"'],
          ),
          ('arrow body with =>', '=> 42;', ['42']),
          ('async arrow body with async =>', 'async => 42;', ['42']),
          ('async* arrow body with async* =>', 'async* => 42;', ['42']),
          ('sync* arrow body with sync* =>', 'sync* => 42;', ['42']),
          ('raw statement block without body prefix', 'final x = 42;', ['42']),
        ]) {
          test('loads literals from snippet with $label', () {
            final filePath = '/test/lib/sample_$label.dart';
            resourceProvider.newFile(filePath, snippet);

            final location = _TestFactory.location(
              filePath,
              length: snippet.length,
            );

            final lits = analyzer.loadExternalLiterals(location);

            expect(lits, isNotNull);
            expect(lits!.map((l) => l.text), equals(expected));
          });
        }
      });
    });
  });
}

abstract final class _TestFactory {
  static LiteralInfo literal(String text, {int offset = 0, int length = 0}) =>
      LiteralInfo(offset: offset, length: length, text: text);

  static List<LiteralInfo> literals(List<String> texts) =>
      texts.map(literal).toList();

  static HashEntry entry({
    int hash = 123,
    int exactHash = 456,
    int lineNumber = 1,
    int offset = 0,
    int length = 0,
    int tokenCount = 4,
  }) => HashEntry(
    hash: hash,
    exactHash: exactHash,
    lineNumber: lineNumber,
    offset: offset,
    length: length,
    tokenCount: tokenCount,
  );

  static DuplicateLocation location(
    String filePath, {
    int offset = 0,
    int length = 0,
  }) => DuplicateLocation(
    filePath: filePath,
    entry: entry(offset: offset, length: length),
  );
}
