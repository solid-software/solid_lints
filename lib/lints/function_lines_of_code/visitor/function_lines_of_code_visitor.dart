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
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

/// The AST visitor that will find lines with code.
class FunctionLinesOfCodeVisitor extends RecursiveAstVisitor<void> {
  final LineInfo _lineInfo;

  final _linesWithCode = <int>{};

  /// Returns the array with indices of lines with code.
  Iterable<int> get linesWithCode => _linesWithCode;

  /// Creates a new instance of [FunctionLinesOfCodeVisitor].
  FunctionLinesOfCodeVisitor(this._lineInfo);

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    _collectFunctionBodyData(
      node.block.leftBracket.next,
      node.block.rightBracket,
    );
    super.visitBlockFunctionBody(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    _collectFunctionBodyData(
      node.expression.beginToken.previous,
      node.expression.endToken.next,
    );
    super.visitExpressionFunctionBody(node);
  }

  void _collectFunctionBodyData(Token? firstToken, Token? lastToken) {
    var token = firstToken;
    while (token != lastToken && token != null) {
      if (!token.isSynthetic) {
        _linesWithCode.add(_lineInfo.getLocation(token.offset).lineNumber);
      }

      token = token.next;
    }
  }
}
