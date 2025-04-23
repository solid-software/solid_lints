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

const _todoComment = 'TODO';

/// The AST visitor that will find all empty blocks, excluding catch blocks
/// and blocks containing [_todoComment]
class NoEmptyBlockVisitor extends RecursiveAstVisitor<void> {
  final bool _allowComments;

  final _emptyBlocks = <Block>[];

  /// Constructor for [NoEmptyBlockVisitor]
  /// [_allowComments] indicates whether to allow empty blocks that contain
  /// any comments
  NoEmptyBlockVisitor({required bool allowComments})
      : _allowComments = allowComments;

  /// All empty blocks
  Iterable<Block> get emptyBlocks => _emptyBlocks;

  @override
  void visitBlock(Block node) {
    super.visitBlock(node);

    if (node.statements.isNotEmpty) return;
    if (node.parent is CatchClause) return;
    if (_allowComments && _isPrecedingCommentAny(node)) return;
    if (_isPrecedingCommentToDo(node)) return;

    _emptyBlocks.add(node);
  }

  static bool _isPrecedingCommentToDo(Block node) =>
      node.endToken.precedingComments?.lexeme.contains(_todoComment) ?? false;

  static bool _isPrecedingCommentAny(Block node) =>
      node.endToken.precedingComments != null;
}
