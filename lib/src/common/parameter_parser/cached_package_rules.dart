import 'package:solid_lints/src/common/parameter_parser/lint_options.dart';

/// Cached rules for a dart package
class CachedPackageRules {
  /// The last modification stamp of the analysis options file
  final int modificationStamp;

  /// Cached rules options by rule name for the package
  final Map<String, LintOptions> rules;

  /// Creates an instance of [CachedPackageRules]
  const CachedPackageRules({
    required this.modificationStamp,
    required this.rules,
  });
}
