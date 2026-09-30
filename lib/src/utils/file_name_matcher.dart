/// Utility class for matching file paths with Dart identifier names.
abstract final class FileNameMatcher {
  static final _alphanumericRegex = RegExp('[^a-zA-Z0-9]');

  static final _pathSeparatorRegex = RegExp(r'[/\\]');

  /// Checks whether the file name of [filePath] matches a Dart
  /// [identifierName] (e.g. `user_profile.dart` matches `UserProfile`).
  static bool matches({
    required String? filePath,
    required String identifierName,
  }) {
    if (filePath == null) return false;
    final fileName = normalizePath(filePath);
    return fileName.isNotEmpty &&
        fileName == normalizeIdentifier(identifierName);
  }

  /// Normalizes a file path to an alphanumeric, lowercase string without
  /// extensions or symbols.
  static String normalizePath(String? path) {
    if (path == null) return '';
    final basename = path.split(_pathSeparatorRegex).last;
    return normalizeIdentifier(basename.split('.').first);
  }

  /// Normalizes a Dart identifier by stripping all non-alphanumeric
  /// characters and converting to lowercase.
  static String normalizeIdentifier(String identifier) =>
      identifier.replaceAll(_alphanumericRegex, '').toLowerCase();
}
