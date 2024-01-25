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
import 'package:solid_lints/src/utils/typecast_utils.dart';

/// AST Visitor which finds all as expressions and checks if they are
/// necessary
class AvoidUnnecessaryTypeCastsVisitor extends RecursiveAstVisitor<void> {
  final _expressions = <Expression, String>{};

  /// All as expressions
  Map<Expression, String> get expressions => _expressions;

  @override
  void visitAsExpression(AsExpression node) {
    super.visitAsExpression(node);

    final objectType = node.expression.staticType;
    final castedType = node.type.type;

    if (objectType == null || castedType == null) {
      return;
    }

    final typeCast = TypeCast(
      source: objectType,
      target: castedType,
    );

    if (typeCast.isUnnecessaryTypeCheck) {
      _expressions[node] = 'as';
    }
  }
}
