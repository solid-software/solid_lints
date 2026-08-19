import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/utils/function_utils.dart';

/// Cached rules for a dart package
class CachedPackageRules {
  /// The last modification stamp of the analysis options file
  final int modificationStamp;

  /// Cached rules options by rule name for the package
  final Map<String, Map<String, Object?>> rules;

  /// Rules that are explicitly disabled
  final Set<String> disabledRules;

  /// Patterns of excluded files
  final Set<String> excludedPatterns;

  final List<Glob> _compiledGlobs;
  final Map<String, bool> _pathExclusionCache = {};

  /// Creates an instance of [CachedPackageRules]
  CachedPackageRules({
    required this.modificationStamp,
    required this.rules,
    required this.disabledRules,
    required this.excludedPatterns,
  }) : _compiledGlobs = _compileGlobs(excludedPatterns);

  static List<Glob> _compileGlobs(Set<String> patterns) => patterns
      .map(
        (pattern) => FunctionUtils.tryOrNull(
          () => Glob(pattern, context: p.posix),
        ),
      )
      .nonNulls
      .toList();

  /// Checks if [filePath] matches any of the excluded patterns.
  bool isPathExcluded(
    String filePath,
    p.Context pathContext,
    String rootDir,
  ) {
    if (excludedPatterns.isEmpty) return false;

    return _pathExclusionCache.putIfAbsent(filePath, () {
      final relativePath = pathContext.isWithin(rootDir, filePath)
          ? pathContext.relative(filePath, from: rootDir)
          : filePath;
      final normalizedPath = p.posix.joinAll(pathContext.split(relativePath));

      return _compiledGlobs.any((glob) => glob.matches(normalizedPath));
    });
  }
}
