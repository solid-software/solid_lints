import 'package:analyzer/dart/ast/token.dart';

/// Extension methods for [Token] manipulation.
extension TokenUtils on Token {
  /// Returns an iterable sequence of all preceding comment tokens before
  /// this token.
  Iterable<CommentToken> get comments sync* {
    for (var c = precedingComments; c != null; c = c.next as CommentToken?) {
      yield c;
    }
  }

  /// Returns an iterable sequence of tokens starting from this token up to
  /// (and including) [end].
  Iterable<Token> upTo(Token end) sync* {
    var current = this;
    while (true) {
      yield current;
      if (current == end) break;
      final next = current.next;
      if (next == null || next == current) break;
      current = next;
    }
  }
}

/// Extension methods for [Iterable<Token>] manipulation.
extension TokenIterableUtils on Iterable<Token> {
  /// Returns all comment lexemes from the tokens in this iterable.
  Iterable<String> get commentLexemes =>
      expand((t) => t.comments).map((c) => c.lexeme);
}
