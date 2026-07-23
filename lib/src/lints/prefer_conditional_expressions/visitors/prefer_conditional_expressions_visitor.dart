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
import 'package:solid_lints/src/lints/prefer_conditional_expressions/models/statement_info.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/prefer_conditional_expressions_rule.dart';
import 'package:solid_lints/src/lints/prefer_conditional_expressions/visitors/conditionals_visitor.dart';

/// The AST visitor that will collect all if statements that can be simplified
/// into conditional expressions.
class PreferConditionalExpressionsVisitor extends RecursiveAstVisitor<void> {
  final PreferConditionalExpressionsRule _rule;
  final bool _ignoreNested;

  /// Creates instance of [PreferConditionalExpressionsVisitor]
  PreferConditionalExpressionsVisitor({
    required PreferConditionalExpressionsRule rule,
    required bool ignoreNested,
  }) : _rule = rule,
       _ignoreNested = ignoreNested;

  @override
  void visitIfStatement(IfStatement node) {
    super.visitIfStatement(node);

    if (_ignoreNested) {
      final visitor = ConditionalsVisitor();
      node.thenStatement.accept(visitor);
      node.elseStatement?.accept(visitor);

      if (visitor.hasInnerConditionals) {
        return;
      }
    }

    final info = StatementInfo.fromIfStatement(node);
    if (info != null) {
      _rule.reportAtNode(node);
    }
  }
}
