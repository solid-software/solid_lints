import 'package:analyzer/dart/ast/ast.dart';

///
abstract class BaseParser {
  ///
  const BaseParser();

  /// Format [documentationComment]
  String? formatDocumentationComment(Comment? documentationComment) =>
      documentationComment?.childEntities
          .join('\n')
          .replaceAll('///', '')
          .trim();

  /// Convert camelCase string to snake_case
  String camelCaseToSnakeCase(String camelCaseString) => camelCaseString
      .replaceAllMapped(
        RegExp('(?<=[a-z])[A-Z]'),
        (Match m) => '_${m.group(0)}',
      )
      .toLowerCase();

  /// Get the dart file name suffix
  String fileNameSuffix(Uri uri) =>
      uri.pathSegments.last.replaceFirst('.dart', '').split('_').last;
}
