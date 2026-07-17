import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// Utility methods for token manipulation.
extension AstNodeTokenCount on AstNode {
  /// Returns the total number of non-EOF tokens within this node.
  int get tokenCount {
    final end = endToken;
    var count = 1;

    for (Token t = beginToken; t != end && t != t.next; t = t.next ?? end) {
      count++;
    }

    return count;
  }
}
