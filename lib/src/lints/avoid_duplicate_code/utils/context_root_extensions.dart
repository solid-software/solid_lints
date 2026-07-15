import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/utils/path_utils.dart';

/// Extension methods for [ContextRoot] to help with file analysis checks.
extension ContextRootExtensions on ContextRoot {
  /// Checks if [filePath] is excluded from analysis by this context root.
  ///
  /// Returns `true` only if the file is within the context root but is
  /// explicitly excluded (e.g., via analysis_options.yaml).
  bool isFileExcluded(String filePath) {
    final isWithin = PathUtils.isWithinOrEqual(root.path, filePath);
    return isWithin && !isAnalyzed(filePath);
  }
}
