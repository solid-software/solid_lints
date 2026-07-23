import 'package:solid_lints/src/lints/avoid_duplicate_code/models/duplicate_location.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';

/// Extension methods for [List] of [HashEntry].
extension HashEntryListExtension on List<HashEntry> {
  /// Converts entries into (hash, DuplicateLocation) tuple pairs for indexing.
  Iterable<(int, DuplicateLocation)> asIndexEntries(
    String absoluteFilePath,
  ) => map(
    (e) => (
      e.hash,
      DuplicateLocation(entry: e, filePath: absoluteFilePath),
    ),
  );
}
