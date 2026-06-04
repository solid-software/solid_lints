import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

/// Extension method to get the reference id of the getter.
extension GetterReferenceId on MethodDeclaration {
  /// Get the reference id of the getter.
  int? get getterReferenceId {
    if (body
        case ExpressionFunctionBody(
          expression: SimpleIdentifier(
            element: PropertyAccessorElement(:final variable)
          )
        )) {
      return variable.id;
    }

    return null;
  }
}
