import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Rule which forbids using bang operator ("!")
/// as it may result in runtime exceptions.
class AvoidNonNullAssertionRule extends DartLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bang operator.
  static const lintName = 'avoid_non_null_assertion';

  /// Creates a new instance of [AvoidNonNullAssertionRule].
  const AvoidNonNullAssertionRule({required super.code});

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
