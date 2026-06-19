import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/cyclomatic_complexity_rule.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/visitors/cyclomatic_complexity_flow_visitor.dart';

/// Visitor that runs [CyclomaticComplexityFlowVisitor] on function,
/// constructor, and method bodies to count their cyclomatic complexity.
class CyclomaticComplexityVisitor extends SimpleAstVisitor<void> {
  final CyclomaticComplexityRule _rule;
  final CyclomaticComplexityParameters _parameters;

  /// Creates a new instance of [CyclomaticComplexityVisitor].
  CyclomaticComplexityVisitor(this._rule, this._parameters);

  void _checkBody(Declaration declaration, FunctionBody? body) {
    if (body == null) return;

    final isIgnored = _parameters.exclude.shouldIgnore(declaration);
    if (isIgnored) return;

    final visitor = CyclomaticComplexityFlowVisitor();
    body.accept(visitor);

    if (visitor.complexityEntities.length + 1 > _parameters.maxComplexity) {
      _rule.reportAtNode(
        body,
        arguments: [_parameters.maxComplexity.toString()],
      );
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkBody(node, node.functionExpression.body);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _checkBody(node, node.body);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkBody(node, node.body);
  }
}
