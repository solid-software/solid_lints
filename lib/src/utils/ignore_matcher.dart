import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/utils/token_utils.dart';

/// Utility class for detecting `// ignore:` and `// ignore_for_file:` comments
/// targeting a specific lint rule.
final class IgnoreMatcher {
  /// The name of the rule being checked.
  final String ruleName;

  late final _fileIgnoreRegex = RegExp(
    '//\\s*ignore_for_file:.*?\\b$ruleName\\b',
    caseSensitive: false,
  );
  late final _lineIgnoreRegex = RegExp(
    '//\\s*ignore:.*?\\b$ruleName\\b',
    caseSensitive: false,
  );

  /// Creates a new instance of [IgnoreMatcher] for [ruleName].
  IgnoreMatcher(this.ruleName);

  /// Checks if the entire [unit] is ignored for [ruleName].
  bool isFileIgnored(CompilationUnit unit) => [
    unit.beginToken,
    for (final directive in unit.directives) directive.beginToken,
    for (final declaration in unit.declarations) declaration.beginToken,
    unit.endToken,
  ].any((t) => t.comments.any((c) => _fileIgnoreRegex.hasMatch(c.lexeme)));

  /// Checks if a candidate [node] or its enclosing [declaration] is ignored.
  bool isCandidateIgnored(AstNode node, [Declaration? declaration]) => [
    if (declaration != null) ...[
      declaration.beginToken,
      declaration.firstTokenAfterCommentAndMetadata,
    ],
    node.beginToken,
  ].any((t) => t.comments.any((c) => _lineIgnoreRegex.hasMatch(c.lexeme)));
}
