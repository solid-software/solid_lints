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

  /// The number of statements in the candidate body.
  final int statementCount;

  /// Creates a new [HashEntry].
  const HashEntry({
    required this.hash,
    required this.lineNumber,
    required this.statementCount,
    this.offset = 0,
    this.length = 0,
  });

  /// Converts this [HashEntry] to a JSON-compatible map using shortened keys.
  Map<String, Object?> toJson() => {
        'h': hash,
        'n': lineNumber,
        'o': offset,
        'l': length,
        's': statementCount,
      };

  /// Creates a [HashEntry] from a JSON map, supporting both old and new keys.
  factory HashEntry.fromJson(Map<String, Object?> json) => HashEntry(
        hash: (json['h'] ?? json['hash'])! as int,
        lineNumber: (json['n'] ?? json['lineNumber'])! as int,
        offset: (json['o'] ?? json['offset'] ?? 0) as int,
        length: (json['l'] ?? json['length'] ?? 0) as int,
        statementCount: (json['s'] ?? json['statementCount'])! as int,
      );
}
