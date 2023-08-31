import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';
import 'package:solid_lints/utils/types_utils.dart';

/// A `avoid-unnecessary-type-assertions` rule which
/// warns about unnecessary usage of `is` and `whereType` operators

class AvoidUnnecessaryTypeAssertions extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid-unnecessary-type-assertions';

  AvoidUnnecessaryTypeAssertions._(super.config);

  /// Creates a new instance of [AvoidUnnecessaryTypeAssertions]
  /// based on the lint configuration.
  factory AvoidUnnecessaryTypeAssertions.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) =>
          'Avoid unnecessary usage of `is` or `whereType` operators',
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
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _isUnnecessaryIsExpression(IsExpression node) {
    final objectType = node.expression.staticType;
    final castedType = node.type.type;

    if (node.notOperator != null) {
      if (objectType != null &&
          objectType is! TypeParameterType &&
          objectType is! DynamicType &&
          !objectType.isDartCoreObject) {
        return _isUnnecessaryTypeCheck(
          objectType,
          castedType,
          isReversed: true,
        );
      }
    }

    return _isUnnecessaryTypeCheck(objectType, castedType);
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

    final objectCastedType = _castedTypeInObjectTypeHierarchy(
      objectType,
      castedType,
    );

    if (objectCastedType == null) {
      return isReversed;
    }

    if (!_isGenerics(objectCastedType, castedType)) {
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

  DartType? _castedTypeInObjectTypeHierarchy(
    DartType objectType,
    DartType castedType,
  ) {
    if (objectType.element == castedType.element) {
      return objectType;
    }

    if (objectType is InterfaceType) {
      return objectType.allSupertypes
          .firstWhereOrNull((value) => value.element == castedType.element);
    }

    return null;
  }

  bool _isGenerics(DartType objectType, DartType castedType) {
    if (objectType is! ParameterizedType || castedType is! ParameterizedType) {
      return false;
    }

    final length = objectType.typeArguments.length;
    if (length != castedType.typeArguments.length) {
      return false;
    }

    for (var argumentIndex = 0; argumentIndex < length; argumentIndex++) {
      if (!_isUnnecessaryTypeCheck(
        objectType.typeArguments[argumentIndex],
        castedType.typeArguments[argumentIndex],
      )) {
        return false;
      }
    }

    return true;
  }
}
