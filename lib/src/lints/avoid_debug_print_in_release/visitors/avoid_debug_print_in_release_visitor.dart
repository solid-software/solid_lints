import 'package:analyzer/dart/ast/ast.dart';
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

  /// Creates an instance of [AvoidDebugPrintInReleaseVisitor].
  AvoidDebugPrintInReleaseVisitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _check(node, node.methodName);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    /// Catch cases where debugPrint is passed as a reference:
    /// final x = debugPrint;
    if (node.parent is! MethodInvocation) {
      _check(node, node);
    }
  }

  void _check(AstNode node, SimpleIdentifier identifier) {
    final element = identifier.element;
    if (element == null) return;

// Check the name
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

        // if (!kReleaseMode)
        if (condition is PrefixExpression &&
            condition.operator.lexeme == '!' &&
            condition.operand is SimpleIdentifier) {
          final operand = condition.operand as SimpleIdentifier;
          if (operand.name == _kReleaseMode) {
            return true;
          }
        }

        // if (kDebugMode)
        if (condition is SimpleIdentifier && condition.name == _kDebugMode) {
          return true;
        }
      }

      parent = parent.parent;
    }

    return false;
  }
}
