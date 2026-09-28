import 'package:solid_lints/src/utils/file_name_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('FileNameMatcher', () {
    group('normalizeIdentifier', () {
      test('converts camelCase to lowercase', () {
        expect(
          FileNameMatcher.normalizeIdentifier('UserProfile'),
          equals('userprofile'),
        );
      });

      test('removes underscores and symbols', () {
        expect(
          FileNameMatcher.normalizeIdentifier('_User_Profile\$123'),
          equals('userprofile123'),
        );
      });

      test('handles empty string', () {
        expect(FileNameMatcher.normalizeIdentifier(''), isEmpty);
      });
    });

    group('normalizePath', () {
      test('returns empty string for null path', () {
        expect(FileNameMatcher.normalizePath(null), isEmpty);
      });

      test('extracts and normalizes basename without extension', () {
        expect(
          FileNameMatcher.normalizePath('/path/to/user_profile.dart'),
          equals('userprofile'),
        );
      });

      test('handles compound extensions by taking first component', () {
        expect(
          FileNameMatcher.normalizePath('user_profile.freezed.dart'),
          equals('userprofile'),
        );
      });

      test('handles Windows style paths', () {
        expect(
          FileNameMatcher.normalizePath(r'C:\project\lib\user_profile.dart'),
          equals('userprofile'),
        );
      });
    });

    group('matches', () {
      test('returns false when filePath is null', () {
        expect(
          FileNameMatcher.matches(
            filePath: null,
            identifierName: 'UserProfile',
          ),
          isFalse,
        );
      });

      test('returns false when filePath is empty', () {
        expect(
          FileNameMatcher.matches(filePath: '', identifierName: 'UserProfile'),
          isFalse,
        );
      });

      test('returns true when normalized names match', () {
        expect(
          FileNameMatcher.matches(
            filePath: '/lib/src/user_profile.dart',
            identifierName: 'UserProfile',
          ),
          isTrue,
        );
      });

      test('returns false when names differ', () {
        expect(
          FileNameMatcher.matches(
            filePath: '/lib/src/account_details.dart',
            identifierName: 'UserProfile',
          ),
          isFalse,
        );
      });
    });
  });
}
