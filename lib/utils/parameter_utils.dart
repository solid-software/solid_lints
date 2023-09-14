import 'package:analyzer/dart/ast/ast.dart';

/// Checks if parameter name consists only of underscores
bool nameIsUnderscores(FormalParameter parameter) {
  final paramName = parameter.name;

  if (paramName == null) return false;

  return paramName.lexeme.replaceAll('_', '').isEmpty;
}
