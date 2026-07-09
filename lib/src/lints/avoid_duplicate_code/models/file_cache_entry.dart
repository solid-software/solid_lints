import 'package:solid_lints/src/lints/avoid_duplicate_code/models/hash_entry.dart';

/// A cache entry containing the file's modification stamp and its structural hashes.
class FileCacheEntry {
  /// The file modification stamp.
  final int modificationStamp;

  /// The list of structural hash entries for this file.
  final List<HashEntry> entries;

  /// Creates a new [FileCacheEntry].
  const FileCacheEntry({
    required this.modificationStamp,
    required this.entries,
  });

  /// Converts this [FileCacheEntry] to a JSON map.
  Map<String, Object?> toJson() => {
        'm': modificationStamp,
        'e': entries.map((e) => e.toJson()).toList(),
      };

  /// Parses a [FileCacheEntry] from a JSON map.
  factory FileCacheEntry.fromJson(Map<String, Object?> json) {
    final entriesList = <HashEntry>[];
    if (json['e'] is List) {
      for (final item in json['e'] as List) {
        if (item is Map<String, Object?>) {
          try {
            entriesList.add(HashEntry.fromJson(item));
          } catch (_) {}
        }
      }
    }
    return FileCacheEntry(
      modificationStamp: (json['m'] as int?) ?? 0,
      entries: entriesList,
    );
  }
}
