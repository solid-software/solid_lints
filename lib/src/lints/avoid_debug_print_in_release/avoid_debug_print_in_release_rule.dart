import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// An `avoid_debug_print_in_release` rule which forbids calling or referencing
/// debugPrint function from flutter/foundation in release mode.
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
/// if (!kReleaseMode) {
///   debugPrint('');
/// }
/// ```
///
///
class AvoidDebugPrintInReleaseRule extends SolidLintRule {
  /// This lint rule represents
  /// the error when debugPrint is called
  static const lintName = 'avoid_debug_print_in_release';

  static const String _kReleaseModePath =
      'package:flutter/src/foundation/constants.dart';
  static const String _kReleaseModeName = 'kReleaseMode';
  static const _debugPrintPath = 'package:flutter/src/foundation/print.dart';
  static const _debugPrintName = 'debugPrint';

  AvoidDebugPrintInReleaseRule._(super.config);

  /// Creates a new instance of [AvoidDebugPrintInReleaseRule]
  /// based on the lint configuration.
  factory AvoidDebugPrintInReleaseRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => """
Avoid using 'debugPrint' in release mode. Wrap 
your `debugPrint` call in a `!kReleaseMode` check.""",
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
    if (!_isDebugPrintNode(identifier)) {
      return;
    }

    final debugCheck = node.thisOrAncestorMatching(
      (node) {
        if (node is IfStatement) {
          return _isNotReleaseCheck(node.expression);
        }

        return false;
      },
    );

    if (debugCheck != null) {
      return;
    }

    reporter.atNode(node, code);
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

  bool _isDebugPrintNode(Identifier node) {
    final String name;
    final String sourcePath;
    switch (node) {
      case PrefixedIdentifier():
        final prefix = node.prefix.name;
        name = node.name.replaceAll('$prefix.', '');
        sourcePath = node.staticElement?.librarySource?.uri.toString() ?? '';

      case SimpleIdentifier():
        name = node.name;
        sourcePath = node.staticElement?.librarySource?.uri.toString() ?? '';

      default:
        return false;
    }

    return name == _debugPrintName && sourcePath == _debugPrintPath;
  }

  bool _isNotReleaseCheck(Expression node) {
    if (node.childEntities.toList()
        case [
          final Token token,
          final Identifier identifier,
        ]) {
      return token.type == TokenType.BANG &&
          _isReleaseModeIdentifier(identifier);
    }

    return false;
  }

  bool _isReleaseModeIdentifier(Identifier node) {
    final String name;
    final String sourcePath;

    switch (node) {
      case PrefixedIdentifier():
        final prefix = node.prefix.name;

        name = node.name.replaceAll('$prefix.', '');
        sourcePath = node.staticElement?.librarySource?.uri.toString() ?? '';
      case SimpleIdentifier():
        name = node.name;
        sourcePath = node.staticElement?.librarySource?.uri.toString() ?? '';
      default:
        return false;
    }

    return name == _kReleaseModeName && sourcePath == _kReleaseModePath;
  }
}
