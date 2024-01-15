import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:solid_lints/utils/docs_parser/models/parameter_doc.dart';
import 'package:solid_lints/utils/docs_parser/parser_utils.dart';

///
class ParametersParser {
  static const _parametersDir = 'models';
  static const _parametersSuffix = 'parameters';

  /// Directory containing rule file
  final Directory ruleDirectory;

  ///
  const ParametersParser({required this.ruleDirectory});

  ///
  List<ParameterDoc> parse() {
    final parametersPath = _getParametersFilePath();
    if (parametersPath == null) return [];

    final ast = parseFile(
      path: parametersPath,
      featureSet: FeatureSet.latestLanguageVersion(),
    );

    final parameterDocs = <ParameterDoc>[];
    for (final declaration in ast.unit.declarations) {
      if (declaration is ClassDeclaration) {
        parameterDocs.addAll(_parseParametersDocs(declaration));
        if (parameterDocs.isNotEmpty) break;
      }
    }

    return parameterDocs;
  }

  List<ParameterDoc> _parseParametersDocs(ClassDeclaration declaration) {
    final List<ParameterDoc> parameterDocs = [];

    for (final member in declaration.members) {
      if (member is FieldDeclaration) {
        final variable = member.fields.variables.first.name;
        final variableName = variable.lexeme.trim();
        if (variableName.startsWith('_')) continue;

        final name = ParserUtils.camelCaseToSnakeCase(variableName);
        final type = member.fields.type.toString();
        final doc = ParserUtils.formatDocumentationComment(
          member.documentationComment,
        );

        if (doc == null) {
          throw 'Documentation is not specified for class: '
              '${declaration.name.stringValue}';
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
    final dir = Directory(join(ruleDirectory.path, _parametersDir));
    if (!dir.existsSync()) return null;

    return dir
        .listSync()
        .firstWhereOrNull(
          (entity) =>
              ParserUtils.fileNameSuffix(entity.uri) == _parametersSuffix,
        )
        ?.path;
  }
}
