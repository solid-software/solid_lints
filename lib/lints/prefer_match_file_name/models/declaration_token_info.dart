import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// Data class represents declaration token and declaration parent node
class DeclarationTokeInfo {
  /// Declaration token
  final Token token;

  /// Declaration parent node
  final AstNode parent;

  /// Creates instance of [DeclarationTokeInfo]
  const DeclarationTokeInfo(this.token, this.parent);
}
