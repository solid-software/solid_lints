// MIT License
//
// Copyright (c) 2020-2021 Dart Code Checker team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// The AST visitor that will collect all if statements that can be simplified
/// into conditional expressions.
class PreferConditionalExpressionsVisitor extends RecursiveAstVisitor<void> {
  final _statementsInfo = <StatementInfo>[];

  final bool _ignoreNested;

  /// List of statement info that represents all simple if statements
  Iterable<StatementInfo> get statementsInfo => _statementsInfo;

  /// Creates instance of [PreferConditionalExpressionsVisitor]
  PreferConditionalExpressionsVisitor({
    required bool ignoreNested,
  }) : _ignoreNested = ignoreNested;

  @override
  void visitIfStatement(IfStatement node) {
    super.visitIfStatement(node);

    if (_ignoreNested) {
      final visitor = _ConditionalsVisitor();
      node.visitChildren(visitor);

      if (visitor.hasInnerConditionals) {
        return;
      }
    }

    if (node.parent is! IfStatement &&
        node.elseStatement != null &&
        node.elseStatement is! IfStatement) {
      _checkBothAssignment(node);
      _checkBothReturn(node);
    }
  }

  void _checkBothAssignment(IfStatement statement) {
    final thenAssignment = _getAssignmentExpression(statement.thenStatement);
    final elseAssignment = _getAssignmentExpression(statement.elseStatement);

    if (thenAssignment != null &&
        elseAssignment != null &&
        _haveEqualNames(thenAssignment, elseAssignment)) {
      _statementsInfo.add(
        StatementInfo(
          statement: statement,
          unwrappedThenStatement: thenAssignment,
          unwrappedElseStatement: elseAssignment,
        ),
      );
    }
  }

  AssignmentExpression? _getAssignmentExpression(Statement? statement) {
    if (statement is ExpressionStatement &&
        statement.expression is AssignmentExpression) {
      return statement.expression as AssignmentExpression;
    }

    if (statement is Block && statement.statements.length == 1) {
      return _getAssignmentExpression(statement.statements.first);
    }

    return null;
  }

  bool _haveEqualNames(
    AssignmentExpression thenAssignment,
    AssignmentExpression elseAssignment,
  ) =>
      thenAssignment.leftHandSide is Identifier &&
      elseAssignment.leftHandSide is Identifier &&
      (thenAssignment.leftHandSide as Identifier).name ==
          (elseAssignment.leftHandSide as Identifier).name;

  void _checkBothReturn(IfStatement statement) {
    final thenReturn = _getReturnStatement(statement.thenStatement);
    final elseReturn = _getReturnStatement(statement.elseStatement);

    if (thenReturn != null && elseReturn != null) {
      _statementsInfo.add(
        StatementInfo(
          statement: statement,
          unwrappedThenStatement: thenReturn,
          unwrappedElseStatement: elseReturn,
        ),
      );
    }
  }

  ReturnStatement? _getReturnStatement(Statement? statement) {
    if (statement is ReturnStatement) {
      return statement;
    }

    if (statement is Block && statement.statements.length == 1) {
      return _getReturnStatement(statement.statements.first);
    }

    return null;
  }
}

class _ConditionalsVisitor extends RecursiveAstVisitor<void> {
  bool hasInnerConditionals = false;

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    hasInnerConditionals = true;

    super.visitConditionalExpression(node);
  }
}

/// Data class contains info required for fix
class StatementInfo {
  /// If statement node
  final IfStatement statement;

  /// Contents of if block
  final AstNode unwrappedThenStatement;

  /// Contents of else block
  final AstNode unwrappedElseStatement;

  /// Creates instance of an [StatementInfo]
  const StatementInfo({
    required this.statement,
    required this.unwrappedThenStatement,
    required this.unwrappedElseStatement,
  });
}
