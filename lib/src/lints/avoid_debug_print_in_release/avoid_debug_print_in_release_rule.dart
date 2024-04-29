import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/models/avoid_debug_print_in_release_debug_model.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/models/avoid_debug_print_in_release_func_model.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A `avoid_debug_print` rule which forbids calling or referencing
/// debugPrint function from flutter/foundation.
///
/// See more here: https://github.com/flutter/flutter/issues/147141
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// debugPrint(''); // LINT
/// var ref = debugPrint; // LINT
/// var ref2;
/// ref2 = debugPrint; // LINT
/// ```
///
/// #### GOOD:
///
/// ```dart
/// if (kDebugMode) {
///   debugPrint('');
/// }
/// ```
///
///
class AvoidDebugPrintInReleaseRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error when debugPrint is called
  static const lintName = 'avoid_debug_print_in_release';

  AvoidDebugPrintInReleaseRule._(super.config);

  /// Creates a new instance of [AvoidDebugPrintInReleaseRule]
  /// based on the lint configuration.
  factory AvoidDebugPrintInReleaseRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => "Avoid using 'debugPrint'",
    );

    return AvoidDebugPrintInReleaseRule._(rule);
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

    // addFunctionReference does not get triggered.
    // addVariableDeclaration and addAssignmentExpression
    // are used as a workaround for simple cases

    context.registry.addVariableDeclaration((node) {
      _handleVariableAssignmentDeclaration(
        node: node,
        reporter: reporter,
      );
    });

    context.registry.addAssignmentExpression((node) {
      _handleVariableAssignmentDeclaration(
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
    final funcModel =
        AvoidDebugPrintInReleaseFuncModel.parseExpression(identifier);

    if (funcModel.isDebugPrint && !_checkIsDebugMode(node)) {
      reporter.reportErrorForNode(code, node);
    }
  }

  bool _checkIsDebugMode(AstNode node) {
    final statement = node.thisOrAncestorOfType<IfStatement>()?.expression;
    final debugModel =
        AvoidDebugPrintInReleaseDebugModel.parseExpression(statement);
    return debugModel.isDebugMode;
  }

  /// Returns null if doesn't have right operand
  SyntacticEntity? _getRightOperand(List<SyntacticEntity> entities) {
    /// Example var t = 15; 15 is in 3d position
    if (entities.length < 3) {
      return null;
    }
    return entities[2];
  }

  /// Handles variable assignment and declaration
  void _handleVariableAssignmentDeclaration({
    required AstNode node,
    required ErrorReporter reporter,
  }) {
    final rightOperand = _getRightOperand(node.childEntities.toList());

    if (rightOperand == null || rightOperand is! Identifier) {
      return;
    }

    _checkIdentifier(
      identifier: rightOperand,
      node: node,
      reporter: reporter,
    );
  }
}
