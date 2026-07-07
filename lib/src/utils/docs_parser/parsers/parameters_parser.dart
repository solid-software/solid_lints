import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:solid_lints/src/utils/docs_parser/models/parameter_doc.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_regexes.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_utils.dart';

/// ParametersParser class to parse parameters of rules
class ParametersParser {
  static const _parametersDir = 'models';
  static const _parametersSuffix = 'parameters';

  /// Directory containing rule file
  final Directory ruleDirectory;

  /// Global map of custom types to their primitives
  final Map<String, String> customTypes;

  ///
  const ParametersParser({
    required this.ruleDirectory,
    required this.customTypes,
  });

  ///
  List<ParameterDoc> parse() {
    final parametersPath = _getParametersFilePath();
    if (parametersPath == null) return [];

    final ast = ParserUtils.parseAst(parametersPath);

    final parameterDocs =
        ast.declarations
            .whereType<ClassDeclaration>()
            .map(_parseParametersDocs)
            .firstWhereOrNull((docs) => docs.isNotEmpty) ??
        [];

    return parameterDocs;
  }

  List<ParameterDoc> _parseParametersDocs(ClassDeclaration declaration) {
    final List<ParameterDoc> parameterDocs = [];

    for (final member in ParserUtils.getClassMembers(declaration)) {
      if (member is! FieldDeclaration || member.isStatic) continue;

      for (final variable in member.fields.variables) {
        final variableName = variable.name.lexeme.trim();
        if (variableName.startsWith('_')) continue;

        final name = ParserUtils.camelCaseToSnakeCase(variableName);
        var type = member.fields.type?.toString() ?? 'dynamic';
        type = type.replaceAllMapped(ParserRegexes.wordRegex, (match) {
          final word = match.group(0)!;
          return customTypes[word] ?? word;
        });

        final doc = member.documentationComment.formatted;

        if (doc == null) {
          throw 'Documentation is not specified for class: '
              '${ParserUtils.getDeclarationName(declaration)}';
        }

        parameterDocs.add(
          ParameterDoc(
            name: name,
            type: type,
            doc: doc,
          ),
        );
      }
    }

    return parameterDocs;
  }

  String? _getParametersFilePath() {
    final ruleName = basename(ruleDirectory.path);
    final filePath = join(
      ruleDirectory.path,
      _parametersDir,
      '${ruleName}_$_parametersSuffix.dart',
    );
    final file = File(filePath);
    return file.existsSync() ? file.path : null;
  }
}
