import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:solid_lints/src/utils/docs_parser/models/parameter_doc.dart';
import 'package:solid_lints/src/utils/docs_parser/utils/parser_extensions.dart';
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
  List<ParameterDoc> parse() =>
      File(
            join(
              ruleDirectory.path,
              _parametersDir,
              '${basename(ruleDirectory.path)}_$_parametersSuffix.dart',
            ),
          ).declarations
          ?.whereType<ClassDeclaration>()
          .map(_parseParametersDocs)
          .firstWhereOrNull((docs) => docs.isNotEmpty) ??
      [];

  List<ParameterDoc> _parseParametersDocs(ClassDeclaration declaration) => [
    for (final member in ParserUtils.getClassMembers(declaration))
      if (member case FieldDeclaration(
        isStatic: false,
        :final documentationComment,
      ))
        for (final v in member.fields.variables)
          if (!v.nameString.startsWith('_'))
            if (documentationComment?.formatted case final doc?)
              ParameterDoc(
                name: ParserUtils.camelCaseToSnakeCase(v.nameString),
                type: (member.fields.type?.toSource() ?? 'dynamic')
                    .replaceAllMapped(ParserRegexes.wordRegex, (match) {
                      final word = match.group(0)!;
                      return customTypes[word] ?? word;
                    }),
                doc: doc,
              )
            else
              throw 'Documentation is not specified for field '
                  '"${v.nameString}" in class: '
                  '${ParserUtils.getDeclarationName(declaration)}',
  ];
}
