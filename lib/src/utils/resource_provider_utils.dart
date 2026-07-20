import 'package:analyzer/file_system/file_system.dart';

/// Extension on [ResourceProvider] to provide folder helpers.
extension ResourceProviderUtils on ResourceProvider {
  /// Ensures that a folder at the path joined from [root] and [dir] exists,
  /// creating it if it doesn't.
  void ensureFolderExists(String root, String dir) =>
      getFolder(pathContext.join(root, dir)).create();
}
