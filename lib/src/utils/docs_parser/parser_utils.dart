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
  static String? formatDocumentationComment(Comment? documentationComment) =>
      documentationComment?.tokens
          .map((token) => token.lexeme)
          .join('\n')
          .replaceAll('///', '')
          .trim();

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
