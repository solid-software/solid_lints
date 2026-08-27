import 'package:analyzer/dart/ast/token.dart';
import 'package:solid_lints/src/utils/iterable_utils.dart';

/// Extension methods for [Token] manipulation.
extension TokenUtils on Token {
  /// Returns an iterable sequence of all preceding comment tokens before
  /// this token.
  Iterable<CommentToken> get comments {
    final first = precedingComments;
    if (first == null) return const [];
    return IterableUtils.iterate(
      first,
      (c) => c.next as CommentToken?,
    );
  }

  /// Returns an iterable sequence of tokens starting from this token up to
  /// (and including) [end].
  Iterable<Token> upTo(Token end) => IterableUtils.iterate(
    this,
    (token) => token == end || token.next == token ? null : token.next,
  );
}

/// Extension methods for [Iterable<Token>] manipulation.
extension TokenIterableUtils on Iterable<Token> {
  /// Returns all comment lexemes from the tokens in this iterable.
  Iterable<String> get commentLexemes =>
      expand((t) => t.comments).map((c) => c.lexeme);
}
