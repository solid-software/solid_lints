import 'package:solid_lints/src/utils/docs_parser/models/rule_doc.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/rule_description_extractor.dart';
import 'package:test/test.dart';

void main() {
  group('RuleDescriptionExtractor', () {
    RuleDoc createRule({required String name, required String doc}) =>
        RuleDoc(name: name, doc: doc, parameters: const []);

    group('extract', () {
      test('returns default fallback when doc is empty', () {
        final rule = createRule(name: 'my_rule', doc: '');

        final result = RuleDescriptionExtractor.extract(rule);

        expect(result, 'Lint rule my_rule for Dart and Flutter.');
      });

      test(
        'returns default fallback when doc starts with markdown heading',
        () {
          final rule = createRule(
            name: 'my_rule',
            doc: '### Example config:\n```yaml\n```',
          );

          final result = RuleDescriptionExtractor.extract(rule);

          expect(result, 'Lint rule my_rule for Dart and Flutter.');
        },
      );

      test('extracts single paragraph description', () {
        final rule = createRule(
          name: 'my_rule',
          doc: 'A comprehensive lint rule description.',
        );

        final result = RuleDescriptionExtractor.extract(rule);

        expect(result, 'A comprehensive lint rule description.');
      });

      test('extracts only the first sentence when paragraph has multiple '
          'sentences', () {
        final rule = createRule(
          name: 'avoid_late',
          doc:
              'Using `late` disables compile time safety. '
              'Instead, a runtime check is made.\n\n'
              '### Example',
        );

        final result = RuleDescriptionExtractor.extract(rule);

        expect(result, 'Using late disables compile time safety.');
      });

      test('removes backticks from description', () {
        final rule = createRule(
          name: 'rule_with_backticks',
          doc:
              'This is a description with `code`.\n\n'
              '### Example config:\n```yaml\n```',
        );

        final result = RuleDescriptionExtractor.extract(rule);

        expect(result, 'This is a description with code.');
      });

      test('stops before code blocks, lists, and reference markers', () {
        final ruleWithList = createRule(
          name: 'list_rule',
          doc: 'Description line.\n- bullet item',
        );
        expect(
          RuleDescriptionExtractor.extract(ruleWithList),
          'Description line.',
        );

        final ruleWithSeeMore = createRule(
          name: 'see_more_rule',
          doc: 'Description line.\nSee more here: https://example.com',
        );
        expect(
          RuleDescriptionExtractor.extract(ruleWithSeeMore),
          'Description line.',
        );
      });
    });
  });
}
