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
  final pathNormalized = normalizePath(
    path,
    rootPath != null ? normalizePath(rootPath) : null,
  );
  if (isIncludeOnly) {
    return _isFileNotIncluded(includeGlobs, path);
  }

  if (isExcludeOnly) {
    return _isFileExcluded(includeGlobs, pathNormalized);
  }

  final isFileNotIncluded = _isFileNotIncluded(includeGlobs, pathNormalized);
  final isFileExcluded = _isFileExcluded(excludeGlobs, pathNormalized);
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

/// Normalizes the path using posix style and
/// replaces backslashes with forward slashes
String normalizePath(String path, [String? root]) {
  // Remove drive letter from path
  final String subpath = _removeDriveLetter(path);

  return p.posix.relative(subpath.replaceAll(r'\', '/'), from: root);
}

String _removeDriveLetter(String path) {
  if (p.context.style != p.Style.windows) {
    return path;
  }

  if (path.contains(":")) {
    final indexOfColon = path.indexOf(':');
    if (indexOfColon == 1 && indexOfColon < path.length - 1) {
      return path.substring(indexOfColon + 1);
    }
  }

  return path;
}
