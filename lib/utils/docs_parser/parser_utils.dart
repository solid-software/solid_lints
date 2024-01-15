import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';

class ParserUtils {
  /// Recursively get files dart with the `rule` suffix in the given [dir]
  static List<String> findRuleFiles(Directory dir) {
    final rulesPaths = <String>[];
    for (final entity in dir.listSync()) {
      if (entity is File) {
        if (fileNameSuffix(entity.uri) == 'rule') {
          rulesPaths.add(entity.path);
        }
      } else if (entity is Directory) {
        rulesPaths.addAll(findRuleFiles(entity));
      }
    }

    return rulesPaths;
  }

  /// Format [documentationComment]
  static String? formatDocumentationComment(Comment? documentationComment) =>
      documentationComment?.childEntities
          .join('\n')
          .replaceAll('///', '')
          .trim();

  /// Convert camelCase string to snake_case
  static String camelCaseToSnakeCase(String camelCaseString) {
    final exp = RegExp(r'(?<=[a-z])[A-Z]');

    return camelCaseString
        .replaceAllMapped(exp, (Match m) => '_${m.group(0)}')
        .toLowerCase();
  }

  /// Get the dart file name suffix
  static String fileNameSuffix(Uri uri) =>
      uri.pathSegments.last.replaceFirst('.dart', '').split('_').last;
}
