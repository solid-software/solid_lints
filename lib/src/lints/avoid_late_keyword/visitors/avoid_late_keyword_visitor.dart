import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/avoid_late_keyword/avoid_late_keyword_rule.dart';

/// Visitor for [AvoidLateKeywordRule].
class AvoidLateKeywordVisitor extends SimpleAstVisitor<void> {
  /// The rule to which the visitor belongs.
  final AvoidLateKeywordRule rule;

  /// Creates an instance of [AvoidLateKeywordVisitor].
  AvoidLateKeywordVisitor(this.rule);

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (!node.isLate) {
      return;
    }

    if (node.initializer != null) {
      return;
    }

    rule.reportAtNode(node);
  }
}
