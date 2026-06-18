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

// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// The AST visitor that will collect cyclomatic complexity of visit nodes in an
///  AST structure.
class CyclomaticComplexityFlowVisitor extends RecursiveAstVisitor<void> {
  final _complexityEntities = <SyntacticEntity>{};

  /// Returns an array of entities that increase cyclomatic complexity.
  Iterable<SyntacticEntity> get complexityEntities => _complexityEntities;

  @override
  void visitAssertStatement(AssertStatement node) {
    _increaseComplexity(node);

    super.visitAssertStatement(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final type = node.operator.type;
    if (type == TokenType.AMPERSAND_AMPERSAND ||
        type == TokenType.BAR_BAR ||
        type == TokenType.QUESTION_QUESTION) {
      _increaseComplexity(node);
    }
    super.visitBinaryExpression(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.operator.type == TokenType.QUESTION_QUESTION_EQ) {
      _increaseComplexity(node);
    }
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.operator.type == TokenType.QUESTION_PERIOD) {
      _increaseComplexity(node);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.operator?.type == TokenType.QUESTION_PERIOD) {
      _increaseComplexity(node);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    if (node.question != null) {
      _increaseComplexity(node);
    }
    super.visitIndexExpression(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    _increaseComplexity(node);

    super.visitCatchClause(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _increaseComplexity(node);

    super.visitConditionalExpression(node);
  }

  @override
  void visitForStatement(ForStatement node) {
    _increaseComplexity(node);

    super.visitForStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _increaseComplexity(node);

    super.visitIfStatement(node);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _increaseComplexity(node);

    super.visitSwitchCase(node);
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _increaseComplexity(node);

    super.visitSwitchDefault(node);
  }

  @override
  void visitSwitchExpressionCase(SwitchExpressionCase node) {
    _increaseComplexity(node);

    super.visitSwitchExpressionCase(node);
  }

  @override
  void visitSwitchPatternCase(SwitchPatternCase node) {
    _increaseComplexity(node);

    super.visitSwitchPatternCase(node);
  }

  @override
  void visitWhenClause(WhenClause node) {
    _increaseComplexity(node);

    super.visitWhenClause(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _increaseComplexity(node);

    super.visitWhileStatement(node);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _increaseComplexity(node);

    super.visitYieldStatement(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Stop recursion into nested function declarations.
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // Stop recursion into nested method declarations.
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Stop recursion into nested function expressions (closures).
  }

  void _increaseComplexity(SyntacticEntity entity) {
    _complexityEntities.add(entity);
  }
}
