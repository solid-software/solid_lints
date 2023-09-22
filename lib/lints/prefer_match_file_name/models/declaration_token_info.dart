import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// Data class represents declaration token and declaration parent node
typedef DeclarationTokenInfo = ({
  /// Declaration token
  Token token,

  /// Declaration parent node
  AstNode parent,
});
