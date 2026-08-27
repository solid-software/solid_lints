import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';

/// Represents a structural duplicate found in other files.
class CrossFileMatch {
  /// The hash entry in the current file.
  final HashEntry currentEntry;

  /// The set of locations in other files where a duplicate of this entry
  /// exists.
  final Set<DuplicateLocation> duplicates;

  /// Creates a new [CrossFileMatch].
  const CrossFileMatch({
    required this.currentEntry,
    required this.duplicates,
  });
}

/// Extension on an iterable of [CrossFileMatch] to group duplicates by hash.
extension CrossFileMatchIterableExtension on Iterable<CrossFileMatch> {
  /// Converts this iterable of cross-file matches to a map of unique duplicates
  /// grouped by entry hash.
  Map<int, Set<DuplicateLocation>> toDuplicatesByHash() => groupFoldBy(
    (match) => match.currentEntry.hash,
    (previous, match) => {...?previous, ...match.duplicates},
  );
}
