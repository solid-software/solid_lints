import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// The AST visitor that will collect every case of field accessing
/// from a different class than the class with a provided `parentClassName`.
class FieldAccessDifferentClassVisitor extends RecursiveAstVisitor<void> {
  final String _parentClassName;
  final _nodes = <AstNode>[];

  /// PropertyAccessVisitorConstructor
  FieldAccessDifferentClassVisitor({required String parentClassName})
      : _parentClassName = parentClassName;

  /// All unnecessary if statements and conditional expressions.
  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    super.visitPrefixedIdentifier(node);

    final identifier = node.identifier.staticElement;

    if (identifier is! PropertyAccessorElement) return;
    // return if variable is synthetic(getter)
    if (identifier.variable.isSynthetic) return;

    final enclosingElement = identifier.enclosingElement;
    if (enclosingElement is! ClassElement) return;
    if (enclosingElement.displayName == _parentClassName) return;

    _nodes.add(node);
  }
}
