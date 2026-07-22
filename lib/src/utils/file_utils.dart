import 'dart:io';

/// Extension on [File] that provides safe, exception-handling methods.
extension FileUtils on File {
  /// Tries to read the file content as a string. Returns `null` if any
  /// exception (such as [FileSystemException] or [FormatException]) is thrown.
  String? tryReadAsStringSync() {
    try {
      return readAsStringSync();
    } catch (_) {
      return null;
    }
  }
}
