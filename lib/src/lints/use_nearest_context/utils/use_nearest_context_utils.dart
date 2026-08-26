import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// Finds the closest BuildContext parameter in the AST parent chain of [node].
FormalParameter? findClosestBuildContext(AstNode node) => node.ancestors
    .whereType<FunctionExpression>()
    .expand((fn) => fn.parameters?.parameters ?? const <FormalParameter>[])
    .firstWhereOrNull((p) => isBuildContext(p.declaredFragment?.element.type));
