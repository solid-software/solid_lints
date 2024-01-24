import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Checks if parameter name consists only of underscores
bool nameConsistsOfUnderscoresOnly(FormalParameter parameter) {
  final paramName = parameter.name;

  if (paramName == null) return false;

  return paramName.lexeme.replaceAll('_', '').isEmpty;
}

/// Decodes the severity parameter from the string
ErrorSeverity? decodeErrorSeverity(String? severity) {
  return switch (severity?.toLowerCase()) {
    'info' => ErrorSeverity.INFO,
    'warning' => ErrorSeverity.WARNING,
    'error' => ErrorSeverity.ERROR,
    'none' => ErrorSeverity.NONE,
    _ => null,
  };
}

/// Extension to create a copy of [LintCode]
extension LintCodeCopyWith on LintCode {
  /// Returns a copy of [LintCode] with specified fields replaced
  LintCode copyWith({
    String? name,
    String? problemMessage,
    String? correctionMessage,
    String? uniqueName,
    String? url,
    ErrorSeverity? errorSeverity,
  }) =>
      LintCode(
        name: name ?? this.name,
        problemMessage: problemMessage ?? this.problemMessage,
        correctionMessage: correctionMessage ?? this.correctionMessage,
        uniqueName: uniqueName ?? this.uniqueName,
        url: url ?? this.url,
        errorSeverity: errorSeverity ?? this.errorSeverity,
      );
}
