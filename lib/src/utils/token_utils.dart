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
}

/// Extension methods for [Iterable<Token>] manipulation.
extension TokenIterableUtils on Iterable<Token> {
  /// Returns all comment lexemes from the tokens in this iterable.
  Iterable<String> get commentLexemes =>
      expand((t) => t.comments).map((c) => c.lexeme);
}
