/// Represents information about a literal found within a code block.
class LiteralInfo {
  /// The string representation of the literal value.
  final String text;

  /// The character offset where the literal begins.
  final int offset;

  /// The character length of the literal.
  final int length;

  /// Creates a new [LiteralInfo].
  const LiteralInfo({
    required this.text,
    required this.offset,
    required this.length,
  });
}
