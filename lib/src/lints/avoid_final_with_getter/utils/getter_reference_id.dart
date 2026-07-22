import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

/// Extension method to get the reference id of the getter.
extension GetterReferenceId on MethodDeclaration {
  /// Get the reference id of the getter.
  int? get getterReferenceId {
    final returnExpression = switch (body) {
      ExpressionFunctionBody(expression: final expr) ||
      BlockFunctionBody(
        block: Block(
          statements: [
            ReturnStatement(expression: final expr?),
          ],
        ),
      ) => expr,
      _ => null,
    };

    final identifier = switch (returnExpression) {
      SimpleIdentifier() => returnExpression,
      PropertyAccess(
        target: ThisExpression(),
        :final propertyName,
      ) =>
        propertyName,
      _ => null,
    };

    return switch (identifier) {
      SimpleIdentifier(element: PropertyAccessorElement(:final variable)) =>
        variable.id,
      _ => null,
    };
  }
}
