import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// This visitor is used to select all SimpleIdentifiers from Expression
class SelectExpressionIdentifiersVisitor extends RecursiveAstVisitor<void> {
  final _identifiers = <SimpleIdentifier>{};

  /// List of SimpleIdentifiers mentioned in expression
  Set<SimpleIdentifier> get identifiers => _identifiers;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);
    _identifiers.add(node);
  }

  /// Helper method to process expression, even if it is a SimpleIdentifier
  void selectFromExpression(Expression expr) {
    if (expr case final SimpleIdentifier identifier) {
      _identifiers.add(identifier);
      return;
    }

    expr.visitChildren(this);
  }
}
