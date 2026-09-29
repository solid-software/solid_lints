import 'package:solid_lints/src/utils/file_name_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('FileNameMatcher', () {
    group('normalizeIdentifier', () {
      test('converts camelCase to lowercase', () {
        expect(
          FileNameMatcher.normalizeIdentifier('UserProfile'),
          'userprofile',
        );
      });

      test('removes underscores and symbols', () {
        expect(
          FileNameMatcher.normalizeIdentifier(r'_User_Profile$123'),
          'userprofile123',
        );
      });

      test('handles empty string', () {
        expect(FileNameMatcher.normalizeIdentifier(''), isEmpty);
      });

      test('handles string with only non-alphanumeric characters', () {
        expect(FileNameMatcher.normalizeIdentifier(r'___---$$$'), isEmpty);
      });
    });

    group('normalizePath', () {
      test('returns empty string for null path', () {
        expect(FileNameMatcher.normalizePath(null), isEmpty);
      });

      test('extracts and normalizes simple filename without path', () {
        expect(
          FileNameMatcher.normalizePath('user_profile.dart'),
          'userprofile',
        );
      });

      test('extracts and normalizes basename from posix path', () {
        expect(
          FileNameMatcher.normalizePath('/path/to/user_profile.dart'),
          'userprofile',
        );
      });

      test('handles compound extensions by taking first component', () {
        expect(
          FileNameMatcher.normalizePath('user_profile.freezed.dart'),
          'userprofile',
        );
      });

      test('handles Windows style paths', () {
        expect(
          FileNameMatcher.normalizePath(r'C:\project\lib\user_profile.dart'),
          'userprofile',
        );
      });

      test('handles package URI paths', () {
        expect(
          FileNameMatcher.normalizePath('package:my_app/src/user_profile.dart'),
          'userprofile',
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

      test('returns false when identifierName is empty', () {
        expect(
          FileNameMatcher.matches(
            filePath: '/lib/src/user_profile.dart',
            identifierName: '',
          ),
          isFalse,
        );
      });

      test('returns false when both normalize to empty string', () {
        expect(
          FileNameMatcher.matches(
            filePath: '/lib/src/---.dart',
            identifierName: '---',
          ),
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

      test('returns true for private identifier matching file name', () {
        expect(
          FileNameMatcher.matches(
            filePath: '/lib/src/user_profile.dart',
            identifierName: '_UserProfile',
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
