import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_using_debug_print/models/avoid_using_debug_print_func_model.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Gives warnings about using debugPrint
///
/// ### Example:
/// ```dart
/// debugPrint(info)
/// ```
class AvoidUsingDebugPrint extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error when debugPrint is called
  static const lintName = 'avoid_using_debug_print';

  AvoidUsingDebugPrint._(super.config);

  /// Creates a new instance of [AvoidUsingDebugPrint]
  /// based on the lint configuration.
  factory AvoidUsingDebugPrint.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => "Avoid using 'debugPrint'",
    );

    return AvoidUsingDebugPrint._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionExpressionInvocation(
      (node) {
        final func = node.function;
        if (func is! Identifier) {
          return;
        }
        _checkIdentifier(
          identifier: func,
          node: node,
          reporter: reporter,
        );
      },
    );

    context.registry.addVariableDeclaration((node) {
      final rightOperand = _getRightOperand(node.childEntities.toList());

      if (rightOperand == null) {
        return;
      }

      if (rightOperand is! Identifier) {
        return;
      }

      _checkIdentifier(
        identifier: rightOperand,
        node: node,
        reporter: reporter,
      );
    });

    context.registry.addAssignmentExpression((node) {
      final rightOperand = _getRightOperand(node.childEntities.toList());

      if (rightOperand == null) {
        return;
      }

      if (rightOperand is! Identifier) {
        return;
      }

      _checkIdentifier(
        identifier: rightOperand,
        node: node,
        reporter: reporter,
      );
    });
  }

  /// Checks whether the function identifier satisfies conditions
  void _checkIdentifier({
    required Identifier identifier,
    required AstNode node,
    required ErrorReporter reporter,
  }) {
    if (!AvoidUsingDebugPrintFuncModel.canParseIdentifier(identifier)) {
      return;
    }

    final funcModel = AvoidUsingDebugPrintFuncModel.parseExpression(identifier);

    if (funcModel.hasSameName && funcModel.hasTheSameSource) {
      reporter.reportErrorForNode(code, node);
    }
  }

  /// Returns null if doesnt have right operand
  SyntacticEntity? _getRightOperand(List<SyntacticEntity> entities) {
    /// Example var t = 15; 15 is in 3d position
    if (entities.length < 3) {
      return null;
    }
    return entities[2];
  }
}
