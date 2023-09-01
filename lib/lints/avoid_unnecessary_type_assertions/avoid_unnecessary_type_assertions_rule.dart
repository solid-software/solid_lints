import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';
import 'package:solid_lints/utils/types_utils.dart';

part 'avoid_unnecessary_type_assertions_fix.dart';

/// A `avoid-unnecessary-type-assertions` rule which
/// warns about unnecessary usage of `is` and `whereType` operators

class AvoidUnnecessaryTypeAssertions extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid-unnecessary-type-assertions';

  static const _unnecessaryIsCode = LintCode(
    name: lintName,
    problemMessage: "Unnecessary usage of the 'is' operator.",
  );

  static const _unnecessaryWhereTypeCode = LintCode(
    name: lintName,
    problemMessage: "Unnecessary usage of the 'whereType' method.",
  );

  AvoidUnnecessaryTypeAssertions._(super.config);

  /// Creates a new instance of [AvoidUnnecessaryTypeAssertions]
  /// based on the lint configuration.
  factory AvoidUnnecessaryTypeAssertions.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => "Unnecessary usage of typecast operators.",
    );

    return AvoidUnnecessaryTypeAssertions._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIsExpression((node) {
      if (_isUnnecessaryIsExpression(node)) {
        reporter.reportErrorForNode(_unnecessaryIsCode, node);
      }
    });

    context.registry.addMethodInvocation((node) {
      if (_isUnnecessaryWhereType(node)) {
        reporter.reportErrorForNode(_unnecessaryWhereTypeCode, node);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_UnnecessaryTypeAssertionsFix()];

  bool _isUnnecessaryIsExpression(IsExpression node) {
    final objectType = node.expression.staticType;
    final castedType = node.type.type;

    if (node.notOperator != null &&
        objectType != null &&
        objectType is! TypeParameterType &&
        objectType is! DynamicType &&
        !objectType.isDartCoreObject &&
        _isUnnecessaryTypeCheck(objectType, castedType, isReversed: true)) {
      return true;
    } else {
      return _isUnnecessaryTypeCheck(objectType, castedType);
    }
  }

  bool _isUnnecessaryWhereType(MethodInvocation node) {
    const whereTypeMethodName = 'whereType';

    final targetType = node.target?.staticType;

    if (node.methodName.name == whereTypeMethodName &&
        isIterable(node.realTarget?.staticType) &&
        targetType is ParameterizedType) {
      final targetHasExplicitTypeArgs = targetType.typeArguments.isNotEmpty;
      final arguments = node.typeArguments?.arguments;
      final invocationHasExplicitTypeArgs = arguments?.isNotEmpty ?? false;

      return targetHasExplicitTypeArgs &&
          invocationHasExplicitTypeArgs &&
          _isUnnecessaryTypeCheck(
            targetType.typeArguments.first,
            arguments?.first.type,
          );
    }
    return false;
  }

  bool _isUnnecessaryTypeCheck(
    DartType? objectType,
    DartType? castedType, {
    bool isReversed = false,
  }) {
    if (objectType == null || castedType == null) {
      return false;
    }

    if (_isNullableCompatibility(objectType, castedType)) {
      return false;
    }

    final objectCastedType = _castTypeInHierarchy(objectType, castedType);

    if (objectCastedType == null) {
      return isReversed;
    }

    if (!_areGenericsWithSameTypeArgs(objectCastedType, castedType)) {
      return false;
    }

    return !isReversed;
  }

  bool _isNullableCompatibility(DartType objectType, DartType castedType) {
    final isObjectTypeNullable = isNullableType(objectType);
    final isCastedTypeNullable = isNullableType(castedType);

    // Only one case `Type? is Type` always valid assertion case.
    return isObjectTypeNullable && !isCastedTypeNullable;
  }

  DartType? _castTypeInHierarchy(DartType objectType, DartType castType) {
    if (objectType.element == castType.element) {
      return objectType;
    }

    if (objectType is InterfaceType) {
      return objectType.allSupertypes
          .firstWhereOrNull((value) => value.element == castType.element);
    }

    return null;
  }

  bool _areGenericsWithSameTypeArgs(DartType objectType, DartType castedType) {
    if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
      return false;
    }

    if (objectType.typeArguments.length != castedType.typeArguments.length) {
      return false;
    }

    return IterableZip([objectType.typeArguments, castedType.typeArguments])
        .every((e) => _isUnnecessaryTypeCheck(e[0], e[1]));
  }
}
