import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Determines whether the file should be skipped using Glob patterns
///
/// See https://pub.dev/packages/glob
bool shouldSkipFile({
  required List<String> includeGlobs,
  required List<String> excludeGlobs,
  required String path,
  String? rootPath,
}) {
  if (includeGlobs.isEmpty && excludeGlobs.isEmpty) {
    return false;
  }

  final bool isIncludeOnly = excludeGlobs.isEmpty && includeGlobs.isNotEmpty;
  final bool isExcludeOnly = includeGlobs.isEmpty && excludeGlobs.isNotEmpty;
  final pathRelativeFromRoot = relativePath(
    path,
    rootPath,
  );
  if (isIncludeOnly) {
    return _isFileNotIncluded(includeGlobs, path);
  }

  if (isExcludeOnly) {
    return _isFileExcluded(includeGlobs, pathRelativeFromRoot);
  }

  final isFileNotIncluded =
      _isFileNotIncluded(includeGlobs, pathRelativeFromRoot);
  final isFileExcluded = _isFileExcluded(excludeGlobs, pathRelativeFromRoot);
  return isFileNotIncluded || isFileExcluded;
}

bool _isFileExcluded(List<String> excludes, String path) {
  final hasMatch =
      excludes.map(Glob.new).toList().any((glob) => glob.matches(path));
  return hasMatch;
}

bool _isFileIncluded(List<String> includes, String path) {
  final hasMatch =
      includes.map(Glob.new).toList().any((glob) => glob.matches(path));
  return hasMatch;
}

bool _isFileNotIncluded(List<String> includes, String path) {
  return !_isFileIncluded(includes, path);
}

/// Converts path to relative using posix style and
/// replaces backslashes with forward slashes
String relativePath(String path, [String? root]) {
  final uriNormlizedPath = p.toUri(path).normalizePath().path;
  final uriNormlizedRoot =
      root != null ? p.toUri(root).normalizePath().path : null;

  final relative = p.posix.relative(uriNormlizedPath, from: uriNormlizedRoot);
  return relative;
}
