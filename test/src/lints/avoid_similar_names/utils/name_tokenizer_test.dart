import 'package:solid_lints/src/lints/avoid_similar_names/utils/name_tokenizer.dart';
import 'package:test/test.dart';

void main() {
  group('NameTokenizer', () {
    test('isSubsetWithNonDescriptiveToken guard clause', () {
      expect(
        NameTokenizer.isSubsetWithNonDescriptiveToken(
          ['a', 'descriptive'],
          ['a', 'descriptive'],
        ),
        isFalse,
      );
      expect(
        NameTokenizer.isSubsetWithNonDescriptiveToken(
          ['a', 'descriptive'],
          ['a'],
        ),
        isFalse,
      );
      expect(
        NameTokenizer.isSubsetWithNonDescriptiveToken(['a', '1'], ['a']),
        isTrue,
      );
      expect(
        NameTokenizer.isSubsetWithNonDescriptiveToken(['a'], ['a', 'b']),
        isFalse,
      );
    });
  });
}
