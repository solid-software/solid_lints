import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// Returns the total number of non-EOF tokens within this node.
int getTokenCount(AstNode node) {
  int count = 0;
  Token? token = node.beginToken;
  final end = node.endToken;
  while (token != null && token != end) {
    count++;
    if (token == token.next) break; // Prevent infinite loop if AST is cyclical
    token = token.next;
  }
  return count + 1;
}
