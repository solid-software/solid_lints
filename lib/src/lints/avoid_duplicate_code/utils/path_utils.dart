import 'package:path/path.dart' as p;

/// Normalizes a file path, ensuring it is absolute and resolved correctly
/// relative to the given [root] if it isn't already absolute.
String normalizePath(String filePath, String root) {
  return p.isAbsolute(filePath)
      ? p.normalize(filePath)
      : p.normalize(p.join(root, filePath));
}
