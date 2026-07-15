import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import 'package:solid_lints/src/utils/docs_parser/utils/parser_regexes.dart';
import 'package:solid_lints/src/utils/file_utils.dart';

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

  static String _cleanCommentLine(String line) => line.substring(switch (line) {
    _ when line.startsWith('/// ') => 4,
    _ when line.startsWith('///') => 3,
    _ => 0,
  });

  /// Format [documentationComment]
  static String? formatDocumentationComment(Comment? documentationComment) =>
      documentationComment?.tokens
          .map((token) => _cleanCommentLine(token.lexeme))
          .join('\n')
          .trim();

  /// Scan the codebase directory for all `{@template}` definitions
  static Map<String, String> scanForTemplates(Directory libDir) => {
    for (final entity in libDir.listSync(recursive: true))
      if (entity case File() when entity.path.endsWith('.dart'))
        if (entity.tryReadAsStringSync() case final content?
            when content.contains('{@template'))
          for (final match in ParserRegexes.templateRegex.allMatches(content))
            if (match.groups([1, 2]) case [
              final String name,
              final String rawContent,
            ])
              name: rawContent
                  .split('\n')
                  .map((line) => _cleanCommentLine(line.trim()))
                  .join('\n')
                  .trim(),
  };

  /// Expand `{@macro}` references in the formatted documentation comment and
  /// strip template tags
  static String expandMacros(
    String text,
    Map<String, String> templates, {
    String? source,
  }) {
    var expanded = text;

    if (expanded.contains('{@macro')) {
      for (var i = 0; i < _maxMacroDepth; i++) {
        final newExpanded = expanded.replaceAllMapped(
          ParserRegexes.macroRegex,
          (match) {
            final name = match.group(1)!;
            final template = templates[name];
            if (template == null) {
              final sourceSuffix = source != null ? ' in $source' : '';
              throw 'Macro reference to non-existent template: '
                  '"$name"$sourceSuffix';
            }
            return template;
          },
        );

        if (newExpanded == expanded) break;

        expanded = newExpanded;

        if (i == _maxMacroDepth - 1 && expanded.contains('{@macro')) {
          final sourceSuffix = source != null ? ' in $source' : '';
          throw 'Circular macro dependency detected or macro expansion depth '
              'exceeded the limit of $_maxMacroDepth$sourceSuffix';
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
  static String fileNameSuffix(Uri uri) => uri.pathSegments.last
      .replaceFirst(RegExp(r'\.dart$'), '')
      .split('_')
      .last;

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
  static String escapeMdx(String text) => text
      .split('`')
      .mapIndexed(
        (i, p) => i.isOdd
            ? p
            : p
                  .replaceAll('<', '&lt;')
                  .replaceAll('>', '&gt;')
                  .replaceAll('{', r'\{')
                  .replaceAll('}', r'\}'),
      )
      .join('`');
}
