import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/function_lines_of_code_rule.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/visitors/function_lines_of_code_visitor.dart';

/// A visitor that reports on functions/methods exceeding the max line limit.
class FunctionLinesOfCodeRuleVisitor extends RecursiveAstVisitor<void> {
  final FunctionLinesOfCodeRule _rule;
  final RuleContext _context;
  final FunctionLinesOfCodeParameters _parameters;

  /// Creates a new instance of [FunctionLinesOfCodeRuleVisitor].
  FunctionLinesOfCodeRuleVisitor(this._rule, this._context, this._parameters);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final isIgnored = _parameters.exclude.shouldIgnore(node);
    if (!isIgnored) {
      _checkNode(node);
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final isIgnored = _parameters.exclude.shouldIgnore(node);
    if (!isIgnored) {
      _checkNode(node);
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.parent is! FunctionDeclaration) {
      _checkNode(node);
    }
    super.visitFunctionExpression(node);
  }

  void _checkNode(AstNode node) {
    final currentUnit = _context.currentUnit;
    if (currentUnit == null) return;

    final lineInfo = currentUnit.unit.lineInfo;
    final visitor = FunctionLinesOfCodeVisitor(lineInfo);
    node.visitChildren(visitor);
    if (visitor.linesWithCode.length <= _parameters.maxLines) return;

    final reporter = currentUnit.diagnosticReporter;
    if (node is! AnnotatedNode) {
      reporter.atNode(
        node,
        _rule.diagnosticCode,
        arguments: [_parameters.maxLines],
      );

      return;
    }

    final startOffset = node.firstTokenAfterCommentAndMetadata.offset;
    final lengthDifference = startOffset - node.offset;

    reporter.atOffset(
      offset: startOffset,
      length: node.length - lengthDifference,
      diagnosticCode: _rule.diagnosticCode,
      arguments: [_parameters.maxLines],
    );
  }
}
