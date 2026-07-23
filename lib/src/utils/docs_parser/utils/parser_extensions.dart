import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_regexes.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_utils.dart';

/// Extension on [File] to help with docs parsing.
extension FileDocsExtension on File {
  /// Whether the file contains document types annotation.
  bool get hasDocStrings =>
      path.endsWith('.dart') && readAsStringSync().contains('@docType');

  /// The compilation unit declarations of the file.
  NodeList<CompilationUnitMember>? get declarations =>
      _tryOrNull(() => ParserUtils.parseAst(path).declarations);
}

/// Extension on [CompilationUnitMember] to help with docs parsing.
extension CompilationUnitMemberDocsExtension on CompilationUnitMember {
  /// The name of the declaration.
  String? get name =>
      _tryOrNull<String?>(() => ParserUtils.getDeclarationName(this));

  /// The formatted documentation comment.
  String? get doc => documentationComment.formatted;

  /// The type corresponding to the documentation comment.
  String? get type => doc == null
      ? null
      : ParserRegexes.docTypeRegex.firstMatch(doc ?? '')?.group(1);
}

T? _tryOrNull<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}

/// Extension on [Comment] to format it easily.
extension CommentExtension on Comment? {
  /// Format the documentation comment.
  String? get formatted => ParserUtils.formatDocumentationComment(this);
}

/// Extension on [VariableDeclaration] to clean up lexeme names.
extension VariableDeclarationExtension on VariableDeclaration {
  /// The lexeme name of the variable, trimmed.
  String get nameString => name.lexeme.trim();
}
