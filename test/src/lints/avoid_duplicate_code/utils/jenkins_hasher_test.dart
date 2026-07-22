import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/jenkins_hasher.dart';
import 'package:test/test.dart';

void main() {
  group('JenkinsHasher', () {
    late JenkinsHasher hasher;

    setUp(() {
      hasher = JenkinsHasher();
    });

    test('initial hash is 0', () {
      expect(hasher.hash, 0);
    });

    test('addString updates hash consistently', () {
      hasher.addString('hello');
      final hash1 = hasher.hash;

      hasher.reset();
      hasher.addString('hello');
      final hash2 = hasher.hash;

      expect(hash1, hash2);
      expect(hash1, isNot(0));
    });

    test('different strings produce different hashes', () {
      hasher.addString('hello');
      final hash1 = hasher.hash;

      hasher.reset();
      hasher.addString('world');
      final hash2 = hasher.hash;

      expect(hash1, isNot(hash2));
    });

    test('addString is equivalent to adding characters sequentially', () {
      hasher.addString('hello');
      final combinedHash = hasher.hash;

      hasher.reset();
      hasher.addString('he');
      hasher.addString('llo');
      final sequentialHash = hasher.hash;

      expect(combinedHash, sequentialHash);
    });

    test('add updates hash correctly', () {
      hasher.add(1);
      hasher.add(2);
      final hash1 = hasher.hash;

      hasher.reset();
      hasher.add(1);
      hasher.add(2);
      final hash2 = hasher.hash;

      expect(hash1, hash2);
    });

    test('reset clears the state', () {
      hasher.addString('some data');
      expect(hasher.hash, isNot(0));

      hasher.reset();
      expect(hasher.hash, 0);
    });
  });
}
