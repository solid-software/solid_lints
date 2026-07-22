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
  final includes = includeGlobs.map(Glob.new).toList();
  final excludes = excludeGlobs.map(Glob.new).toList();

  final relative = relativePath(path, rootPath);

  final matchesInclude =
      includes.isEmpty ||
      _matchesAny(includes, relative) ||
      _matchesAny(includes, path);

  final matchesExclude =
      excludes.isNotEmpty &&
      (_matchesAny(excludes, relative) || _matchesAny(excludes, path));

  return !matchesInclude || matchesExclude;
}

bool _matchesAny(List<Glob> globs, String path) =>
    globs.any((glob) => glob.matches(path));

/// Converts path to relative using posix style and
/// replaces backslashes with forward slashes
String relativePath(String path, [String? root]) {
  final uriNormalizedPath = p.toUri(path).normalizePath().path;
  final uriNormalizedRoot = root != null
      ? p.toUri(root).normalizePath().path
      : null;

  return p.posix.relative(uriNormalizedPath, from: uriNormalizedRoot);
}

/// Checks if the given [libraryUri] matches the [targetSource] string
/// (either exact match or as a directory/package prefix).
/// Returns `false` if [libraryUri] is null.
bool matchesSource(String? libraryUri, String targetSource) =>
    libraryUri != null &&
    (libraryUri == targetSource || libraryUri.startsWith('$targetSource/'));
