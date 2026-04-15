import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/avoid_debug_print_in_release_rule.dart';

/// Visitor for [AvoidDebugPrintInReleaseRule].
class AvoidDebugPrintInReleaseRuleVisitor extends SimpleAstVisitor<void> {
  /// The rule associated with this visitor.
  final AvoidDebugPrintInReleaseRule rule;

  /// Creates an instance of [AvoidDebugPrintInReleaseRuleVisitor].
  AvoidDebugPrintInReleaseRuleVisitor(this.rule);

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
    if (element.name == 'debugPrint') {
      // Check if it's from the flutter/foundation path
      final sourceUri = element.library?.uri.toString() ?? '';
      final isFlutterFoundation =
          sourceUri.contains('package:flutter/foundation.dart');

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
        final expression = parent.expression;
        final source = expression.toString();

        if (source.contains('kReleaseMode') || source.contains('kDebugMode')) {
          return true;
        }
      }
      parent = parent.parent;
    }
    return false;
  }
}
