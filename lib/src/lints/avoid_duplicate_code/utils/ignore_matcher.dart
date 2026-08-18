import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/utils/token_utils.dart';

/// Utility class for detecting `// ignore:` and `// ignore_for_file:` comments
/// targeting `avoid_duplicate_code`.
abstract final class IgnoreMatcher {
  static final _fileIgnoreRegex = RegExp(
    r'//\s*ignore_for_file:.*?\bavoid_duplicate_code\b',
    caseSensitive: false,
  );

  static final _lineIgnoreRegex = RegExp(
    r'//\s*ignore:.*?\bavoid_duplicate_code\b',
    caseSensitive: false,
  );

  /// Checks if the entire [unit] is ignored for `avoid_duplicate_code`.
  static bool isFileIgnored(CompilationUnit unit) => [
    unit.beginToken,
    for (final directive in unit.directives) directive.beginToken,
  ].any((t) => t.comments.any((c) => _fileIgnoreRegex.hasMatch(c.lexeme)));

  /// Checks if a candidate [node] or its enclosing [declaration] is ignored.
  static bool isCandidateIgnored(AstNode node, Declaration? declaration) => [
    if (declaration != null) ...[
      declaration.beginToken,
      declaration.firstTokenAfterCommentAndMetadata,
    ],
    node.beginToken,
  ].any((t) => t.comments.any((c) => _lineIgnoreRegex.hasMatch(c.lexeme)));
}
