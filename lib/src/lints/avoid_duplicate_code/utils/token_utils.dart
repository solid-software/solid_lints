import 'package:analyzer/dart/ast/ast.dart';

/// Returns the total number of non-EOF tokens within this node.
int getTokenCount(AstNode node) {
  int count = 0;
  var token = node.beginToken;
  final end = node.endToken;
  while (token != end) {
    count++;
    token = token.next!;
  }
  return count + 1;
}
