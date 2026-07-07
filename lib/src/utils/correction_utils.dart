import 'package:analysis_server_plugin/edit/correction_utils.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';

/// Extension on [CorrectionUtils] to provide utilities for creating
/// [SourceRange]s and parsing comments.
extension CorrectionUtilsExtension on CorrectionUtils {
  /// Creates a [SourceRange] from [start] and [end] offsets.
  SourceRange createRange(int start, int end) =>
      SourceRange(start, end - start);

  /// Returns the text of the range from [start] to [end].
  String getTextRange(int start, int end) =>
      getRangeText(createRange(start, end));

  /// Finds trailing comment on the same line as this [node].
  String? getTrailingComment({
    required AstNode node,
    required int nextOffset,
  }) {
    if (node.end >= nextOffset) return null;

    final sameLine = getTextRange(node.end, nextOffset)
        .split('\n')
        .first;

    final commentIdx = sameLine.indexOf('//');

    return commentIdx != -1 ? sameLine.substring(commentIdx) : null;
  }

  /// Finds leading comment, skipping any trailing comment that belongs
  /// to the previous node (same line as previous node).
  Token? getLeadingComment({
    required AstNode node,
    int? previousEnd,
  }) {
    Token? comment = node.beginToken.precedingComments;
    if (previousEnd == null) return comment;

    for (; comment != null; comment = comment.next) {
      if (getTextRange(previousEnd, comment.offset).contains('\n')) {
        return comment;
      }
    }

    return null;
  }

  /// Computes the start offset of a [node]'s declaration,
  /// including leading comments and indentation if applicable.
  int getDeclarationStartOffset({
    required AstNode node,
    required Token? leadingComment,
    required int minOffset,
  }) {
    final hasValidComment = leadingComment != null &&
        leadingComment.offset >= minOffset &&
        leadingComment.offset < node.offset;

    final blockStart = hasValidComment ? leadingComment.offset : node.offset;

    final lineStart = getLineThis(blockStart);
    final prefixText = getTextRange(lineStart, blockStart);

    final isLineStartWhitespace = prefixText.trim().isEmpty;

    return isLineStartWhitespace ? lineStart : blockStart;
  }
}
