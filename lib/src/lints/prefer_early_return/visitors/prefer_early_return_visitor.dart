import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/prefer_early_return/prefer_early_return_rule.dart';

/// Visitor for [PreferEarlyReturnRule].
class PreferEarlyReturnVisitor extends RecursiveAstVisitor<void> {
  /// The rule associated with the visitor.
  final PreferEarlyReturnRule rule;

  /// Constructor for [PreferEarlyReturnVisitor].
  PreferEarlyReturnVisitor({
    required this.rule,
  });

  @override
  void visitIfStatement(IfStatement node) {
    if (_shouldReport(node)) {
      rule.reportAtNode(node);
    }

    super.visitIfStatement(node);
  }

  bool _shouldReport(IfStatement node) {
    final parent = node.parent;

    return parent is Block &&
        parent.statements.length == 1 &&
        node.elseStatement == null;
  }
}
