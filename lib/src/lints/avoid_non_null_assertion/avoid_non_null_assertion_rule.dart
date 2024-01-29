import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Rule which warns about usages of bang operator ("!")
/// as it may result in unexpected runtime exceptions.
///
/// "Bang" operator with Maps is allowed, as [Dart docs](https://dart.dev/null-safety/understanding-null-safety#the-map-index-operator-is-nullable)
/// recommend using it for accessing Map values that are known to be present.
///
/// ### Example
/// #### BAD:
///
/// ```dart
/// Object? object;
/// int? number;
///
/// final int computed = 1 + number!; // LINT
/// object!.method(); // LINT
/// ```
///
/// #### GOOD:
/// ```dart
/// Object? object;
/// int? number;
///
/// if (number != null) {
///   final int computed = 1 + number;
/// }
/// object?.method();
///
/// // No lint on maps
/// final map = {'key': 'value'};
/// map['key']!;
/// ```
class AvoidNonNullAssertionRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bang operator.
  static const lintName = 'avoid_non_null_assertion';

  AvoidNonNullAssertionRule._(super.config);

  /// Creates a new instance of [AvoidNonNullAssertionRule]
  /// based on the lint configuration.
  factory AvoidNonNullAssertionRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => 'Avoid using the bang operator. '
          'It may result in runtime exceptions.',
    );

    return AvoidNonNullAssertionRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPostfixExpression((node) {
      if (node.operator.type != TokenType.BANG) {
        return;
      }

      // DCM's and Flutter's documentation treats "bang" as a valid way of
      // accessing a Map. For compatibility it's excluded from this rule.
      // See more:
      // * https://dcm.dev/docs/rules/common/avoid-non-null-assertion
      // * https://dart.dev/null-safety/understanding-null-safety#the-map-index-operator-is-nullable
      final operand = node.operand;
      if (operand is IndexExpression) {
        final type = operand.target?.staticType;
        final isInterface = type is InterfaceType;
        final isMap = isInterface &&
            (type.isDartCoreMap ||
                type.allSupertypes.any((v) => v.isDartCoreMap));

        if (isMap) {
          return;
        }
      }

      reporter.reportErrorForNode(code, node);
    });
  }
}
