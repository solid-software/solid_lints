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

/// Represents a structural duplicate found in other files.
class CrossFileMatch {
  /// The hash entry in the current file.
  final HashEntry currentEntry;

  /// The list of locations in other files where a duplicate of this entry
  /// exists.
  final List<DuplicateLocation> duplicates;

  /// Creates a new [CrossFileMatch].
  const CrossFileMatch({
    required this.currentEntry,
    required this.duplicates,
  });
}
