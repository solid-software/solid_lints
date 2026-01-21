import 'dart:io';

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

/// Finds the appropriate analysis options file for the given file path
/// Supports hierarchical search for nested analysis_options.yaml files
String? findAnalysisOptionsForFile(String filePath) {
  final directory = p.dirname(filePath);
  return _findSpecificAnalysisOptions(directory, 'analysis_options.yaml');
}

/// Recursively searches for a specific analysis options file
String? _findSpecificAnalysisOptions(String dirPath, String fileName) {
  final analysisOptions = p.join(dirPath, fileName);
  if (File(analysisOptions).existsSync()) {
    return analysisOptions;
  }

  final parent = p.dirname(dirPath);

  /// Reached filesystem root
  if (parent == dirPath) return null;

  if (!_isWithinProject(parent)) return null;

  return _findSpecificAnalysisOptions(parent, fileName);
}

/// Checking if we are still in project
bool _isWithinProject(String dirPath) {
  try {
    final dir = Directory(dirPath);

    /// Using custom_lint logic to find project directory
    final projectDir = _findProjectDirectory(dir);
    return projectDir != null;
  } catch (e) {
    return false;
  }
}

/// Finds the project directory (contains pubspec.yaml)
Directory? _findProjectDirectory(Directory directory) {
  if (File(p.join(directory.path, 'pubspec.yaml')).existsSync()) {
    return directory;
  }

  if (directory.parent.uri == directory.uri) {
    return null;
  }

  return _findProjectDirectory(directory.parent);
}
