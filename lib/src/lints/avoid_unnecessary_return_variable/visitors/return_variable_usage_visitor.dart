import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_return_variable/avoid_unnecessary_return_variable_rule.dart';

/// Visitor for [AvoidUnnecessaryReturnVariableRule] which checks whether the
/// return variable is used somewhere except return statement and
/// whether it is immutable.
class ReturnVariableUsageVisitor extends RecursiveAstVisitor<void> {
  final ReturnStatement _returnStatement;
  final LocalVariableElement _returnVariableElement;

  /// After visiting holds the declaration of return variable
  VariableDeclaration? variableDeclaration;

  /// After visiting holds info about whether there are any tokens
  bool foundTokensBetweenDeclarationAndReturn = false;

  /// The problem expects that exactly 1 mention of return variable.
  /// VariableDeclarationStatement doesn't count when visiting SimpleIdentifier.
  /// Any other amount of variable mentions implies that it is used somewhere
  /// except return, so its existence is justified.
  static const _badStatementCount = 1;

  int _variableStatementCounter = 0;

  /// Defines whether the variables is used in return statement only.
  bool hasBadStatementCount() =>
      _variableStatementCounter == _badStatementCount;

  /// Creates a new instance of [ReturnVariableUsageVisitor].
  ReturnVariableUsageVisitor(
    this._returnStatement,
    this._returnVariableElement,
  );

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    if (_collectVariableDeclaration(node)) {
      _checkTokensInBetween(node, _returnStatement);
    }
    super.visitVariableDeclarationStatement(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.element?.id == _returnVariableElement.id) {
      _variableStatementCounter++;
    }

    super.visitSimpleIdentifier(node);
  }

  bool _collectVariableDeclaration(VariableDeclarationStatement node) {
    final targetVariable = node.variables.variables.firstWhereOrNull(
      (v) => v.declaredFragment?.element.id == _returnVariableElement.id,
    );
    if (targetVariable == null) return false;
    variableDeclaration = targetVariable;

    return true;
  }

  void _checkTokensInBetween(
    VariableDeclarationStatement variableDeclaration,
    ReturnStatement returnStatement,
  ) {
    final tokenBeforeReturn =
        _returnStatement.findPrevious(_returnStatement.beginToken);

    if (tokenBeforeReturn != variableDeclaration.endToken) {
      foundTokensBetweenDeclarationAndReturn = true;
    }
  }
}
