import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:collection/collection.dart';

/// This visitor is searches all uses of a single local variable,
/// including variable declaration.
class AvoidUnnecessaryReturnVariableVisitor extends RecursiveAstVisitor<void> {
  /// The problem expects that exactly 1 mention of return variable.
  /// VariableDeclarationStatement doesn't count when visiting SimpleIdentifier.
  /// Any other amount of variable mentions implies that it is used somewhere
  /// except return, so its existance is justified.
  static const _badStatementCount = 1;

  final LocalVariableElement2 _returnVariableElement;

  bool _foundTokensBetweenDeclarationAndReturn = false;
  VariableDeclaration? _variableDeclaration;
  int _variableStatementCounter = 0;

  final ReturnStatement _returnStatement;

  /// After visiting holds info about whether there are any tokens
  /// between variable declaration and return statement
  bool get foundTokensBetweenDeclarationAndReturn =>
      _foundTokensBetweenDeclarationAndReturn;

  /// Returns statement of local variable declaration
  VariableDeclaration? get variableDeclaration => _variableDeclaration;

  /// Creates a new instance of [AvoidUnnecessaryReturnVariableVisitor].
  AvoidUnnecessaryReturnVariableVisitor(
    this._returnVariableElement,
    this._returnStatement,
  );

  /// Defines whether the variables is used in return statement only.
  bool hasBadStatementCount() =>
      _variableStatementCounter == _badStatementCount;

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
      (v) => v.declaredElement2?.id == _returnVariableElement.id,
    );
    if (targetVariable == null) return false;

    _variableDeclaration = targetVariable;
    return true;
  }

  void _checkTokensInBetween(
    VariableDeclarationStatement variableDeclaration,
    ReturnStatement returnStatement,
  ) {
    final tokenBeforeReturn =
        _returnStatement.findPrevious(_returnStatement.beginToken);

    if (tokenBeforeReturn != variableDeclaration.endToken) {
      _foundTokensBetweenDeclarationAndReturn = true;
    }
  }
}
