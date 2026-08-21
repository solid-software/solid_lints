import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/literal_info.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/literal_collector_visitor.dart';
import 'package:test/test.dart';

void main() {
  group('LiteralCollectorVisitor', () {
    test(
      'collects signed and unsigned number, string, boolean, symbol literals',
      () {
        final literals = _collect('''
void test() {
  final a = 10;
  final b = -20;
  final c = 3.14;
  final d = -1.5;
  final e = 'hello';
  final f = true;
  final g = false;
  final h = #mySymbol;
}
''');

        expect(literals.map((l) => l.text).toList(), [
          '10',
          '-20',
          '3.14',
          '-1.5',
          "'hello'",
          'true',
          'false',
          '#mySymbol',
        ]);
      },
    );

    test('collects string parts of string interpolation', () {
      final literals = _collect(r'''
void test(String name, String category) {
  final msg = 'Hello $name, welcome to $category!';
}
''');

      expect(literals.map((l) => l.text).toList(), [
        "'Hello '",
        "', welcome to '",
        "'!'",
      ]);
    });

    test(
      'collects literals inside collections and function call arguments',
      () {
        final literals = _collect('''
void test() {
  final list = [1, 'two'];
  final map = {'key': 3};
  print(4, true);
}
''');

        expect(literals.map((l) => l.text).toList(), [
          '1',
          "'two'",
          "'key'",
          '3',
          '4',
          'true',
        ]);
      },
    );

    test('collects boolean literal inside not expression', () {
      final literals = _collect('''
void test(bool flag) {
  final a = !true;
  final b = !flag;
}
''');

      expect(literals.map((l) => l.text).toList(), ['true']);
    });

    test('records accurate source offset and length for each literal', () {
      const content = '''
void test() {
  final count = 42;
  final name = 'solid';
}
''';
      final literals = _collect(content);

      expect(literals, hasLength(2));
      for (final literal in literals) {
        final snippet = content.substring(
          literal.offset,
          literal.offset + literal.length,
        );
        expect(snippet, literal.text);
      }
    });

    test('returns empty list when no literals are present', () {
      final literals = _collect('''
void test(int a, int b) {
  final sum = a + b;
}
''');

      expect(literals, isEmpty);
    });
  });
}

List<LiteralInfo> _collect(String content) =>
    LiteralCollectorVisitor.collect(parseString(content: content).unit);
