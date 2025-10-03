import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/typecast_utils.dart';
import 'package:solid_lints/src/utils/types_utils.dart';

part 'fixes/avoid_unnecessary_type_assertions_fix.dart';

/// The name of 'is' operator
const operatorIsName = 'is';

/// The name of 'whereType' method
const whereTypeMethodName = 'whereType';

/// Warns about unnecessary usage of `is` and `whereType` operators.
///
/// ### Example:
/// #### BAD:
/// ```dart
/// final testList = [1.0, 2.0, 3.0];
/// final result = testList is List<double>; // LINT
/// final negativeResult = testList is! List<double>; // LINT
/// testList.whereType<double>(); // LINT
///
/// final double d = 2.0;
/// final casted = d is double; // LINT
/// ```
///
/// #### GOOD:
/// ```dart
/// final dynamicList = <dynamic>[1.0, 2.0];
/// dynamicList.whereType<double>();
///
/// final double? nullableD = 2.0;
/// // casting `Type? is Type` is allowed
/// final castedD = nullableD is double;
/// ```
class AvoidUnnecessaryTypeAssertions extends SolidLintRule {
  /// This lint rule represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'avoid_unnecessary_type_assertions';

  static const _unnecessaryIsCode = LintCode(
    name: lintName,
    problemMessage: "Unnecessary usage of the '$operatorIsName' operator.",
  );

  static const _unnecessaryWhereTypeCode = LintCode(
    name: lintName,
    problemMessage: "Unnecessary usage of the '$whereTypeMethodName' method.",
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
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addIsExpression((node) {
      if (_isUnnecessaryIsExpression(node)) {
        reporter.atNode(node, _unnecessaryIsCode);
      }
    });

    context.registry.addMethodInvocation((node) {
      if (_isUnnecessaryWhereType(node)) {
        reporter.atNode(node, _unnecessaryWhereTypeCode);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_UnnecessaryTypeAssertionsFix()];

  bool _isUnnecessaryIsExpression(IsExpression node) {
    final objectType = node.expression.staticType;
    final castedType = node.type.type;

    if (objectType == null || castedType == null) {
      return false;
    }
    final typeCast = TypeCast(
      source: objectType,
      target: castedType,
      isReversed: node.notOperator != null,
    );
    return typeCast.isUnnecessaryTypeCheck;
  }

  bool _isUnnecessaryWhereType(MethodInvocation node) {
    if (node
        case MethodInvocation(
          methodName: Identifier(name: whereTypeMethodName),
          target: Expression(staticType: final targetType),
          realTarget: Expression(staticType: final realTargetType),
          typeArguments: TypeArgumentList(arguments: final arguments),
        )
        when targetType is ParameterizedType &&
            isIterable(realTargetType) &&
            arguments.isNotEmpty) {
      final objectType = targetType.typeArguments.first;
      final castedType = arguments.first.type;

      if (castedType == null) {
        return false;
      }

      final typeCast = TypeCast(source: objectType, target: castedType);

      return typeCast.isUnnecessaryTypeCheck;
    } else {
      return false;
    }
  }
}
