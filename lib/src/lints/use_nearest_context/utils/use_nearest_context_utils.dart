import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// Finds the closest BuildContext parameter in the AST parent chain of [node].
SimpleFormalParameter? findClosestBuildContext(AstNode node) {
  AstNode? current = node.parent;

  while (current != null) {
    if (current is FunctionExpression) {
      final functionParams = current.parameters?.parameters ?? [];
      for (final param in functionParams) {
        final actualParam =
            param is DefaultFormalParameter ? param.parameter : param;
        if (actualParam is SimpleFormalParameter &&
            isBuildContext(actualParam.declaredFragment?.element.type)) {
          return actualParam;
        }
      }
    }
    current = current.parent;
  }
  return null;
}
