import 'package:analyzer/file_system/file_system.dart';

/// Extension on [ResourceProvider] to provide file and folder helpers.
extension ResourceProviderUtils on ResourceProvider {
  /// Ensures that a folder at the path joined from [root] and [dir] exists,
  /// creating it if it doesn't.
  void ensureFolderExists(String root, String dir) =>
      getFolder(pathContext.join(root, dir)).create();

  /// Reads file content at [path] if it exists, otherwise returns an empty
  /// string.
  ///
  /// Returns an empty string if the file does not exist or cannot be read.
  /// Guards against a TOCTOU race where the file is deleted or becomes
  /// unreadable between the existence check and the actual read (e.g. during
  /// an active editor session).
  String readFileContent(String path) {
    final file = getFile(path);
    if (!file.exists) return '';

    try {
      return file.readAsStringSync();
    } on FileSystemException {
      return '';
    }
  }
}
