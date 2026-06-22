import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/use_nearest_context/use_nearest_context_rule.dart';
import 'package:solid_lints/src/lints/use_nearest_context/utils/use_nearest_context_utils.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

/// A visitor for [UseNearestContextRule].
class UseNearestContextVisitor extends SimpleAstVisitor<void> {
  final UseNearestContextRule _rule;

  /// Creates a new instance of [UseNearestContextVisitor].
  UseNearestContextVisitor(this._rule);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!isBuildContext(node.staticType)) return;
    if (node.isPropertyOfOtherObject) return;

    final closestBuildContext = findClosestBuildContext(node);
    if (closestBuildContext == null) return;
    if (closestBuildContext.name?.lexeme == node.name) return;
    if (node.isDeclaredInSameFunction(as: closestBuildContext)) return;

    _rule.reportAtNode(node);
  }

  @override
  void visitThisExpression(ThisExpression node) {
    if (!isBuildContext(node.staticType)) return;

    final closestBuildContext = findClosestBuildContext(node);
    if (closestBuildContext == null) return;

    _rule.reportAtNode(node);
  }
}
