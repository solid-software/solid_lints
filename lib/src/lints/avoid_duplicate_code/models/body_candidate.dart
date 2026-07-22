import 'package:analyzer/dart/ast/ast.dart';

/// A record representing a block or expression candidate for clone detection.
typedef BodyCandidate = ({
  AstNode node,
  Declaration? enclosingDeclaration,
});
