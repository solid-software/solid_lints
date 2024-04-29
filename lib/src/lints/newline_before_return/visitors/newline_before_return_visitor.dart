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

/// The AST visitor that will all return statements.
class NewLineBeforeReturnVisitor extends RecursiveAstVisitor<void> {
  final LineInfo _lineInfo;
  final _statements = <ReturnStatement>[];

  /// Creates instance of [NewLineBeforeReturnVisitor] with line info
  NewLineBeforeReturnVisitor(this._lineInfo);

  /// List of all return statements
  Iterable<ReturnStatement> get statements => _statements;

  @override
  void visitReturnStatement(ReturnStatement node) {
    super.visitReturnStatement(node);

    if (!_statementIsInBlock(node)) return;
    if (_statementIsFirstInBlock(node)) return;
    if (_statementHasNewLineBefore(node, _lineInfo)) return;

    _statements.add(node);
  }

  static bool _statementIsInBlock(ReturnStatement node) => node.parent is Block;

  static bool _statementIsFirstInBlock(ReturnStatement node) =>
      node.returnKeyword.previous == node.parent?.beginToken;

  static bool _statementHasNewLineBefore(
    ReturnStatement node,
    LineInfo lineInfo,
  ) {
    final previousTokenLineNumber =
        lineInfo.getLocation(node.returnKeyword.previous!.end).lineNumber;

    final lastNotEmptyLineToken = _optimalToken(node.returnKeyword, lineInfo);
    final tokenLineNumber =
        lineInfo.getLocation(lastNotEmptyLineToken.offset).lineNumber;

    return tokenLineNumber > previousTokenLineNumber + 1;
  }

  /// If return statement has comment above ignores all the comment lines
  static Token _optimalToken(Token token, LineInfo lineInfo) {
    var optimalToken = token;

    var commentToken = _latestCommentToken(token);
    while (commentToken != null &&
        lineInfo.getLocation(commentToken.end).lineNumber + 1 >=
            lineInfo.getLocation(optimalToken.offset).lineNumber) {
      optimalToken = commentToken;
      commentToken = commentToken.previous;
    }

    return optimalToken;
  }

  static Token? _latestCommentToken(Token token) {
    Token? latestCommentToken = token.precedingComments;
    while (latestCommentToken?.next != null) {
      latestCommentToken = latestCommentToken?.next;
    }

    return latestCommentToken;
  }
}
