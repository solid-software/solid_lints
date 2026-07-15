/// Utility class for tokenizing identifiers and
/// comparing name similarity.
abstract final class NameTokenizer {
  /// Regex pattern to match camelCase/snake_case tokens:
  /// - `[A-Z]?[a-z]+` : Words (e.g., Class, user)
  /// - `[A-Z]+`       : Acronyms (e.g., URL, ID)
  /// - `\d+`          : Numeric sequences (e.g., 1, 10)
  static final _tokenPattern = RegExp(r'[A-Z]?[a-z]+|[A-Z]+|\d+');

  static const _allowedTokens = {'x', 'y', 'z', 'w', 'i', 'j', 'k'};

  /// Splits a camelCase or snake_case identifier
  /// into lowercase tokens.
  ///
  /// E.g., `someClass1` returns `['some', 'class', '1']`.
  static List<String> tokenize(String name) => [
    for (final match in _tokenPattern.allMatches(name))
      match.group(0)!.toLowerCase(),
  ];

  /// Strips leading underscores from a name.
  ///
  /// E.g., `_someName` returns `someName`.
  static String cleanName(String name) => name.replaceFirst(RegExp('^_+'), '');

  /// Returns `true` if the string consists only
  /// of digit characters.
  static bool isDigit(String s) => int.tryParse(s) != null;

  /// Returns `true` if the token is a common
  /// loop variable or coordinate name.
  static bool isAllowedToken(String s) => _allowedTokens.contains(s);

  /// Returns `true` if the token is considered non-descriptive
  /// (either a digit or a disallowed single letter).
  static bool isNonDescriptiveToken(String s) =>
      isDigit(s) || (s.length == 1 && !isAllowedToken(s));

  /// Returns `true` if [longer] is a superset of
  /// [shorter] with exactly one extra non-descriptive token.
  static bool isSubsetWithNonDescriptiveToken(
    List<String> longer,
    List<String> shorter,
  ) {
    var i = 0;
    while (i < shorter.length && longer[i] == shorter[i]) {
      i++;
    }
    if (!isNonDescriptiveToken(longer[i])) return false;
    while (i < shorter.length && longer[i + 1] == shorter[i]) {
      i++;
    }
    return i == shorter.length;
  }
}
