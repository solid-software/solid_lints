import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';

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

/// Extension on an iterable of [CrossFileMatch] to group duplicates by hash.
extension CrossFileMatchIterableExtension on Iterable<CrossFileMatch> {
  /// Converts this iterable of cross-file matches to a map of duplicates
  /// grouped by hash.
  Map<int, List<DuplicateLocation>> toDuplicatesByHash() => {
    for (final match in this) match.currentEntry.hash: match.duplicates,
  };
}
