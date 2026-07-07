import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import 'package:solid_lints/src/utils/docs_parser/utils/parser_regexes.dart';

/// Utils used by parsers
class ParserUtils {
  static const _maxMacroDepth = 5;
  static const _lintNameVariable = 'lintName';

  ParserUtils._();

  /// Parse a Dart file and return its [CompilationUnit]
  static CompilationUnit parseAst(String path) => parseFile(
    path: path,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).unit;

  static String _cleanCommentLine(String line) {
    if (line.startsWith('/// ')) {
      return line.substring(4);
    }
    if (line.startsWith('///')) {
      return line.substring(3);
    }
    return line;
  }

  /// Format [documentationComment]
  static String? formatDocumentationComment(Comment? documentationComment) {
    if (documentationComment == null) return null;
    return documentationComment.tokens
        .map((token) => _cleanCommentLine(token.lexeme))
        .join('\n')
        .trim();
  }

  /// Scan the codebase directory for all `{@template}` definitions
  static Map<String, String> scanForTemplates(Directory libDir) {
    final templates = <String, String>{};

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      try {
        final content = entity.readAsStringSync();
        if (!content.contains('{@template')) continue;

        for (final match in ParserRegexes.templateRegex.allMatches(content)) {
          final name = match.group(1)!;
          final rawContent = match.group(2)!;
          final cleanContent = rawContent
              .split('\n')
              .map((line) => _cleanCommentLine(line.trim()))
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
    var expanded = text;

    if (expanded.contains('{@macro')) {
      for (var i = 0; i < _maxMacroDepth; i++) {
        final newExpanded = expanded.replaceAllMapped(
          ParserRegexes.macroRegex,
          (match) {
            final name = match.group(1)!;
            final template = templates[name];
            if (template == null) {
              throw 'Macro reference to non-existent template: "$name"';
            }
            return template;
          },
        );

        if (newExpanded == expanded) break;

        expanded = newExpanded;

        if (i == _maxMacroDepth - 1 && expanded.contains('{@macro')) {
          throw 'Circular macro dependency detected or macro expansion depth '
              'exceeded the limit of $_maxMacroDepth';
        }
      }
    }

    expanded = expanded.replaceAll(ParserRegexes.templateTagRegex, '');

    return expanded.trim();
  }

  /// Convert camelCase string to snake_case
  static String camelCaseToSnakeCase(String camelCaseString) => camelCaseString
      .replaceAllMapped(
        ParserRegexes.camelCaseRegex,
        (Match m) => '_${m.group(0)}',
      )
      .toLowerCase();

  /// Get the dart file name suffix
  static String fileNameSuffix(Uri uri) =>
      p.basenameWithoutExtension(uri.path).split('_').last;

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

  /// Safely get the value of static const lintName from a [ClassDeclaration]
  static String? getLintName(ClassDeclaration classDeclaration) {
    final initializer = getClassMembers(classDeclaration)
        .whereType<FieldDeclaration>()
        .where((member) => member.isStatic)
        .expand((member) => member.fields.variables)
        .firstWhereOrNull((v) => v.name.lexeme == _lintNameVariable)
        ?.initializer;

    return initializer is StringLiteral ? initializer.stringValue : null;
  }

  /// Find the `lib` directory by traversing up from the given [startDir]
  static Directory findLibDir(Directory startDir) {
    var current = startDir.absolute;
    while (current.path != current.parent.path) {
      if (p.basename(current.path) == 'lib') {
        return current;
      }
      current = current.parent;
    }
    final localLib = Directory(p.join(Directory.current.path, 'lib'));
    if (localLib.existsSync()) return localLib;
    return startDir;
  }

  /// Escape angle brackets `<` and `>` in plain text (outside of code blocks)
  /// to make the text safe for Docusaurus MDX parser.
  static String escapeMdx(String text) {
    final parts = text.split('`');
    for (var i = 0; i < parts.length; i++) {
      if (i.isEven) {
        parts[i] = parts[i]
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('{', r'\{')
            .replaceAll('}', r'\}');
      }
    }
    return parts.join('`');
  }
}

/// Extension on [Comment] to format it easily.
extension CommentExtension on Comment? {
  /// Format the documentation comment.
  String? get formatted => ParserUtils.formatDocumentationComment(this);
}
