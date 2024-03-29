import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// The AST visitor that will collect every case of field accessing
/// from a different class than the class with a provided `parentClassName`.
class FieldAccessVisitor extends RecursiveAstVisitor<void> {
  final ClassDeclaration _parentClass;
  final _thisClassAccessList = <AstNode>[];
  final _externalClassAccessList = <AstNode>[];

  /// PropertyAccessVisitorConstructor
  FieldAccessVisitor({required ClassDeclaration parentClass})
      : _parentClass = parentClass;

  /// List of fields/methods accessed that are declared in the same
  /// class as `parentClass`
  Iterable<AstNode> get thisClassAccessList => _thisClassAccessList;

  /// List of fields/methods accessed that are declared in a class
  /// different from `parentClass`
  Iterable<AstNode> get externalClassAccessList => _externalClassAccessList;

  /// Returns true if `externalClassAccessList.length` is greater than
  /// `thisClassAccessList.length`
  bool get isFeatureEnvy =>
      _externalClassAccessList.length > _thisClassAccessList.length;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    final element = node.staticElement;
    if (element == null) return;
    if (element is! PropertyAccessorElement && element is! MethodElement) {
      return;
    }

    final enclosingElement = element.enclosingElement;
    if (enclosingElement is! ClassElement) return;

    if (enclosingElement.name == _parentClass.name.toString()) {
      _thisClassAccessList.add(node);
    } else {
      _externalClassAccessList.add(node);
    }
  }
}
