import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Utils used by parsers
class ParserUtils {
  /// Regex to find @docType annotations in doc comments
  static final docTypeRegex = RegExp(r'@docType\s+(.+)$', multiLine: true);

  /// Regex to match words/tokens in types
  static final wordRegex = RegExp(r'\b\w+\b');

  static final _camelCaseRegex = RegExp('(?<=[a-z])[A-Z]');

  ParserUtils._();

  /// Parse a Dart file and return its [CompilationUnit]
  static CompilationUnit parseAst(String path) => parseFile(
    path: path,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).unit;

  /// Format [documentationComment]
  static String? formatDocumentationComment(Comment? documentationComment) {
    if (documentationComment == null) return null;
    return documentationComment.tokens
        .map((token) {
          final lexeme = token.lexeme;
          if (lexeme.startsWith('/// ')) {
            return lexeme.substring(4);
          } else if (lexeme == '///') {
            return '';
          } else if (lexeme.startsWith('///')) {
            return lexeme.substring(3);
          }
          return lexeme;
        })
        .join('\n')
        .trim();
  }

  /// Scan the codebase directory for all `{@template}` definitions
  static Map<String, String> scanForTemplates(Directory libDir) {
    final templates = <String, String>{};
    final templateRegex = RegExp(
      r'{@template\s+([a-zA-Z0-9_\.-]+)\}([\s\S]*?){@endtemplate\}',
    );

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      try {
        final content = entity.readAsStringSync();
        for (final match in templateRegex.allMatches(content)) {
          final name = match.group(1)!;
          final rawContent = match.group(2)!;
          final cleanContent = rawContent
              .split('\n')
              .map((line) {
                final trimmed = line.trim();
                if (trimmed.startsWith('/// ')) {
                  return trimmed.substring(4);
                } else if (trimmed == '///') {
                  return '';
                } else if (trimmed.startsWith('///')) {
                  return trimmed.substring(3);
                }
                return trimmed;
              })
              .join('\n')
              .trim();

          templates[name] = cleanContent;
        }
      } catch (_) {}
    }
    return templates;
  }

  /// Expand `{@macro}` references in the formatted documentation comment and
  /// strip template tags
  static String expandMacros(String text, Map<String, String> templates) {
    final macroRegex = RegExp(r'{@macro\s+([a-zA-Z0-9_\.-]+)\}');
    var expanded = text;

    for (var i = 0; i < 5; i++) {
      final newExpanded = expanded.replaceAllMapped(macroRegex, (match) {
        final name = match.group(1)!;
        return templates[name] ?? '';
      });
      if (newExpanded == expanded) break;
      expanded = newExpanded;
    }

    final templateTagRegex = RegExp(
      r'{@template\s+[a-zA-Z0-9_\.-]+\}|{@endtemplate\}',
    );
    expanded = expanded.replaceAll(templateTagRegex, '');

    return expanded.trim();
  }

  /// Convert camelCase string to snake_case
  static String camelCaseToSnakeCase(String camelCaseString) => camelCaseString
      .replaceAllMapped(
        _camelCaseRegex,
        (Match m) => '_${m.group(0)}',
      )
      .toLowerCase();

  /// Get the dart file name suffix
  static String fileNameSuffix(Uri uri) =>
      uri.pathSegments.last.replaceFirst('.dart', '').split('_').last;

  /// Safely get the name of a ClassDeclaration or EnumDeclaration
  static String? getDeclarationName(CompilationUnitMember declaration) =>
      switch (declaration) {
        ClassDeclaration() => declaration.namePart.typeName.lexeme,
        EnumDeclaration() => declaration.namePart.typeName.lexeme,
        _ => null,
      };

  /// Safely get members of a ClassDeclaration
  static List<ClassMember> getClassMembers(ClassDeclaration declaration) {
    final body = declaration.body;
    return body is BlockClassBody ? body.members : [];
  }
}
