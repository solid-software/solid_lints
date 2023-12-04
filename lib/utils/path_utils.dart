import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Determines whether the file should be skipped using Glob patterns
///
/// There are three modes:
/// 1. Include only - only files matching [includeGlobs] will be
///    included
/// 2. Exclude only - all files will be included except those
///    matching [excludeGlobs]
/// 3. Include and exclude - only files matching [includeGlobs]
///    and not matching [excludeGlobs] will be included
///
/// See https://pub.dev/packages/glob
bool shouldSkipFile({
  required List<String> includeGlobs,
  required List<String> excludeGlobs,
  required String path,
  String? rootPath,
}) {
  final relative = relativePath(path, rootPath);
  final shouldAnalyzeFile =
      (includeGlobs.isEmpty || _matchesAnyGlob(includeGlobs, relative)) &&
          (excludeGlobs.isEmpty || _doesNotMatchGlobs(excludeGlobs, relative));
  return !shouldAnalyzeFile;
}

bool _matchesAnyGlob(List<String> globsList, String path) {
  final hasMatch =
      globsList.map(Glob.new).toList().any((glob) => glob.matches(path));
  return hasMatch;
}

bool _doesNotMatchGlobs(List<String> globList, String path) {
  return !_matchesAnyGlob(globList, path);
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
