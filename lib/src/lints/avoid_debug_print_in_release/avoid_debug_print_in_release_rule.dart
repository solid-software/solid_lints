import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class AvoidDebugPrintInReleaseRule extends AnalysisRule {
  /// The name of the lint
  static const String lintName = 'avoid_debug_print_in_release';

  static const LintCode code = LintCode(
    lintName,
    "Avoid using 'debugPrint' in release mode.",
    correctionMessage: 'Wrap your debugPrint call in a !kReleaseMode check.',
  );

  AvoidDebugPrintInReleaseRule()
      : super(
          name: lintName,
          description:
              'Forbids calling or referencing debugPrint outside !kReleaseMode checks.',
        );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);

    registry.addFunctionExpressionInvocation(this, visitor);
    registry.addVariableDeclaration(this, visitor);
    registry.addAssignmentExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidDebugPrintInReleaseRule rule;

  _Visitor(this.rule);
  static const String _kReleaseModePath =
      'package:flutter/src/foundation/constants.dart';
  static const String _kReleaseModeName = 'kReleaseMode';
  static const String _debugPrintPath =
      'package:flutter/src/foundation/print.dart';
  static const String _debugPrintName = 'debugPrint';

  @override
  void visitFunctionExpressionInvocation(
    FunctionExpressionInvocation node,
  ) {
    final func = node.function;
    if (func is! Identifier) return;

    _checkIdentifier(identifier: func, node: node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _handleVariableAssignmentDeclaration(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _handleVariableAssignmentDeclaration(node);
  }

  void _checkIdentifier({
    required Identifier identifier,
    required AstNode node,
  }) {
    if (!_isDebugPrintNode(identifier)) {
      return;
    }

    final debugCheck = node.thisOrAncestorMatching((node) {
      if (node is IfStatement) {
        return _isNotReleaseCheck(node.expression);
      }
      return false;
    });

    if (debugCheck != null) {
      return;
    }

    rule.reportAtNode(node);
  }

  SyntacticEntity? _getRightOperand(List<SyntacticEntity> entities) {
    if (entities.length < 3) {
      return null;
    }
    return entities[2];
  }

  void _handleVariableAssignmentDeclaration(AstNode node) {
    final rightOperand = _getRightOperand(node.childEntities.toList());

    if (rightOperand is! Identifier) {
      return;
    }

    _checkIdentifier(
      identifier: rightOperand,
      node: node,
    );
  }

  bool _isDebugPrintNode(Identifier node) {
    final String name;
    final String sourcePath;

    switch (node) {
      case PrefixedIdentifier():
        final prefix = node.prefix.name;
        name = node.name.replaceAll('$prefix.', '');
        sourcePath = node.element?.library?.uri.toString() ?? '';
      case SimpleIdentifier():
        name = node.name;
        sourcePath = node.element?.library?.uri.toString() ?? '';
      default:
        return false;
    }

    return name == _debugPrintName && sourcePath == _debugPrintPath;
  }

  bool _isNotReleaseCheck(Expression node) {
    if (node.childEntities.toList()
        case [final Token token, final Identifier identifier]) {
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
        sourcePath = node.element?.library?.uri.toString() ?? '';
      case SimpleIdentifier():
        name = node.name;
        sourcePath = node.element?.library?.uri.toString() ?? '';
      default:
        return false;
    }

    return name == _kReleaseModeName && sourcePath == _kReleaseModePath;
  }
}
