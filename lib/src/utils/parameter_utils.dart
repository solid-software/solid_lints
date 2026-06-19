import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as error;

/// Checks if parameter name consists only of underscores
bool nameConsistsOfUnderscoresOnly(FormalParameter parameter) {
  final paramName = parameter.name;

  if (paramName == null) return false;

  return paramName.lexeme.replaceAll('_', '').isEmpty;
}

/// Decodes the severity parameter from the string
error.DiagnosticSeverity? decodeErrorSeverity(String? severity) {
  return switch (severity?.toLowerCase()) {
    'info' => error.DiagnosticSeverity.INFO,
    'warning' => error.DiagnosticSeverity.WARNING,
    'error' => error.DiagnosticSeverity.ERROR,
    'none' => error.DiagnosticSeverity.NONE,
    _ => null,
  };
}
