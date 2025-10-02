import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_initstate_field_initialization/avoid_initstate_field_initialization_rule.dart';
// import 'package:analyzer/dart/element/element2.dart';
// import 'package:collection/collection.dart';

/// TODO DESCRIPTION
class AvoidInitstateFieldInitializationVisitor extends SimpleAstVisitor<void> {
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    node.visitChildren(this);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    super.visitMethodDeclaration(node);

    if (node.name.toString() !=
        AvoidInitstateFieldInitializationRule.initState) {
      return;
    }

    AstNode body = node.body;
    while (body.childEntities.firstOrNull != null) {
      if (body.childEntities.first is! AstNode) break;
      body = body.childEntities.first as AstNode;
    }

    body.visitChildren(this);
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    super.visitExpressionStatement(node);
    node.visitChildren(this);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    super.visitAssignmentExpression(node);

    if (node.leftHandSide case final SimpleIdentifier field
        //when field.element is FieldElement2
        ) {
      _processVisitedVariable(node, field);
    }
  }

  void _processVisitedVariable(
    AssignmentExpression node,
    SimpleIdentifier identifier,
  ) {
    //TODO: why identifier.element is this null?
    print("$node ; $identifier ; ${identifier.element}");
  }
}
