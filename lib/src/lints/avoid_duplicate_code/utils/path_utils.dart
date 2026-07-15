import 'package:path/path.dart' as p;

/// Utility methods for path manipulation and comparison.
abstract final class PathUtils {
  /// Normalizes a file path, ensuring it is absolute and resolved correctly
  /// relative to the given [root] if it isn't already absolute.
  static String normalizePath(String filePath, String root) {
    return p.isAbsolute(filePath)
        ? p.normalize(filePath)
        : p.normalize(p.join(root, filePath));
  }

  /// Checks if [filePath] is equal to [parentPath] or is located within it.
  static bool isWithinOrEqual(String parentPath, String filePath) {
    return p.equals(parentPath, filePath) || p.isWithin(parentPath, filePath);
  }
}
