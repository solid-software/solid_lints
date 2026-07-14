import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';

/// Represents a location in the codebase where a duplicate was found.
class DuplicateLocation {
  /// The matching hash entry in the other file.
  final HashEntry entry;

  /// The absolute path of the other file.
  final String filePath;

  /// Creates a new [DuplicateLocation].
  const DuplicateLocation({
    required this.entry,
    required this.filePath,
  });
}
