/// A single structural hash entry representing a function body or block
/// candidate for cross-file clone detection.
class HashEntry {
  /// The structural hash of the AST subtree.
  final int hash;

  /// The line number where this candidate starts.
  final int lineNumber;

  /// The character offset from the start of the file.
  final int offset;

  /// The length of the code block.
  final int length;

  /// The number of tokens in the candidate body.
  final int tokenCount;

  /// Creates a new [HashEntry].
  const HashEntry({
    required this.hash,
    required this.lineNumber,
    required this.tokenCount,
    this.offset = 0,
    this.length = 0,
  });

  /// Converts this [HashEntry] to a JSON-compatible map using shortened keys.
  Map<String, Object?> toJson() => {
    'h': hash,
    'n': lineNumber,
    'o': offset,
    'l': length,
    't': tokenCount,
  };

  /// Creates a [HashEntry] from a JSON map.
  factory HashEntry.fromJson(Map<String, Object?> json) => HashEntry(
    hash: json['h']! as int,
    lineNumber: json['n']! as int,
    offset: (json['o'] ?? 0) as int,
    length: (json['l'] ?? 0) as int,
    tokenCount: (json['t'] ?? json['s'] ?? 0) as int,
  );
}
