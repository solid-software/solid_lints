import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_type_assertions/avoid_unnecessary_type_assertions_rule.dart';
import 'package:solid_lints/src/utils/typecast_utils.dart';

/// Visitor for [AvoidUnnecessaryTypeAssertionsRule].
/// Reports on unnecessary usage of 'whereType' method.
///
/// ### Example:
/// {@template solid_lints.avoid_unnecessary_type_assertions.example_where}
/// #### `whereType` method
///
/// ##### BAD:
/// ```dart
/// final testList = [1.0, 2.0, 3.0];
/// testList.whereType<double>(); // LINT
/// ```
///
/// ##### GOOD:
/// ```dart
/// final dynamicList = <dynamic>[1.0, 2.0];
/// dynamicList.whereType<double>();
/// ```
/// {@endtemplate}
class UnnecessaryWhereTypeVisitor extends SimpleAstVisitor<void> {
  final AvoidUnnecessaryTypeAssertionsRule _rule;

  /// Creates a new instance of [UnnecessaryWhereTypeVisitor]
  UnnecessaryWhereTypeVisitor(this._rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    if (!_isUnnecessaryWhereType(node)) return;

    _rule.reportAtNode(
      node,
      arguments: [
        "'${AvoidUnnecessaryTypeAssertionsRule.whereTypeMethodName}' method",
      ],
    );
  }

  bool _isUnnecessaryWhereType(MethodInvocation node) {
    if (node case MethodInvocation(
      methodName: Identifier(
        name: AvoidUnnecessaryTypeAssertionsRule.whereTypeMethodName,
      ),
      target: Expression(staticType: final InterfaceType targetType),
      typeArguments: TypeArgumentList(:final arguments),
    ) when arguments.isNotEmpty) {
      final targetIterableType = switch (targetType) {
        InterfaceType(isDartCoreIterable: true) => targetType,
        InterfaceType(:final allSupertypes) => allSupertypes.firstWhereOrNull(
          (e) => e.isDartCoreIterable,
        ),
      };

      final objectType = targetIterableType?.typeArguments.firstOrNull;
      final castedType = arguments.first.type;

      if (castedType == null || objectType == null) {
        return false;
      }

      final typeCast = TypeCast(source: objectType, target: castedType);

      return typeCast.isUnnecessaryTypeCheck;
    }

    return false;
  }
}
