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

import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:solid_lints/src/lints/newline_before_return/newline_before_return_rule.dart';

/// Visitor for [NewlineBeforeReturnRule].
class NewLineBeforeReturnVisitor extends RecursiveAstVisitor<void> {
  final NewlineBeforeReturnRule _rule;

  final RuleContext _context;

  /// Creates instance of [NewLineBeforeReturnVisitor] with line info
  NewLineBeforeReturnVisitor(this._rule, this._context);

  @override
  void visitReturnStatement(ReturnStatement node) {
    super.visitReturnStatement(node);

    final source = _context.allUnits.first.content;

    if (!_statementIsInBlock(node)) return;
    if (_statementIsFirstInBlock(node)) return;
    if (_statementHasNewLineBefore(node, source)) return;

    _rule.reportAtNode(node);
  }

  static bool _statementIsInBlock(ReturnStatement node) => node.parent is Block;

  static bool _statementIsFirstInBlock(ReturnStatement node) =>
      node.returnKeyword.previous == node.parent?.beginToken;

  static bool _statementHasNewLineBefore(
    ReturnStatement node,
    String source,
  ) {
    final previousToken = node.returnKeyword.previous!;

    final lastNotEmptyLineToken = _optimalToken(node.returnKeyword, source);

    return _hasBlankLineBetween(
      previousToken,
      lastNotEmptyLineToken,
      source,
    );
  }

  /// If return statement has comment above ignores all the comment lines
  static Token _optimalToken(Token token, String source) {
    var optimalToken = token;

    var commentToken = _latestCommentToken(token);

    while (commentToken != null &&
        !_hasBlankLineBetween(commentToken, optimalToken, source)) {
      optimalToken = commentToken;
      commentToken = commentToken.previous;
    }

    return optimalToken;
  }

  static Token? _latestCommentToken(Token token) {
    Token? latestCommentToken = token.precedingComments;

    if (latestCommentToken == null) return null;

    while (latestCommentToken!.next != null) {
      latestCommentToken = latestCommentToken.next;
    }

    return latestCommentToken;
  }

  static bool _hasBlankLineBetween(Token a, Token b, String source) {
    final aEnd = a.end;
    final bStart = b.offset;

    if (aEnd > bStart) return false;

    final between = source.substring(aEnd, bStart);
    final hasBlankLine = between.contains(RegExp(r'\n[ \t]*\r?\n'));

    return hasBlankLine;
  }
}
