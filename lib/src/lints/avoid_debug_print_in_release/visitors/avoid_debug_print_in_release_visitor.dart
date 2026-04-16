import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/avoid_debug_print_in_release_rule.dart';

/// Visitor for [AvoidDebugPrintInReleaseRule].
class AvoidDebugPrintInReleaseVisitor extends SimpleAstVisitor<void> {
  /// The rule associated with this visitor.
  final AvoidDebugPrintInReleaseRule rule;
  static const _foundationUri = 'package:flutter/foundation.dart';
  static const _debugPrint = 'debugPrint';
  static const _kReleaseMode = 'kReleaseMode';
  static const _kDebugMode = 'kDebugMode';
  static const _callMethod = 'call';

  /// Creates an instance of [AvoidDebugPrintInReleaseVisitor].
  AvoidDebugPrintInReleaseVisitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    final methodName = node.methodName;

    if (methodName.name == _callMethod && target is SimpleIdentifier) {
      _check(node, target);
      return;
    }

    _check(node, methodName);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.parent is! MethodInvocation) {
      _check(node, node);
    }
  }

  void _check(AstNode node, SimpleIdentifier identifier) {
    final element = identifier.element;
    if (element == null) return;

    if (element.name == _debugPrint) {
      final sourceUri = element.library?.uri.toString() ?? '';

      final isFlutterFoundation = sourceUri.contains(
        _foundationUri,
      );

      if (isFlutterFoundation) {
        if (!_isWrappedInReleaseCheck(node)) {
          rule.reportAtNode(identifier);
        }
      }
    }
  }

  bool _isWrappedInReleaseCheck(AstNode node) {
    AstNode? parent = node.parent;

    while (parent != null) {
      if (parent is IfStatement) {
        final condition = parent.expression;

        if (_isNotReleaseModeCheck(condition) || _isDebugModeCheck(condition)) {
          return true;
        }
      }

      parent = parent.parent;
    }

    return false;
  }

  bool _isNotReleaseModeCheck(Expression condition) {
    return condition is PrefixExpression &&
        condition.operator.type == TokenType.BANG &&
        condition.operand is SimpleIdentifier &&
        (condition.operand as SimpleIdentifier).name == _kReleaseMode;
  }

  bool _isDebugModeCheck(Expression condition) {
    return condition is SimpleIdentifier && condition.name == _kDebugMode;
  }
}
