import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// Utility methods for token manipulation.
abstract final class TokenUtils {
  /// Returns the total number of non-EOF tokens within this node.
  static int getTokenCount(AstNode node) {
    int count = 0;
    Token? token = node.beginToken;
    final end = node.endToken;
    while (token != null && token != end) {
      count++;
      if (token == token.next) return count;
      token = token.next;
    }
    return count + 1;
  }
}
