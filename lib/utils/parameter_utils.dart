import 'package:analyzer/dart/ast/ast.dart';

/// Checks if parameter has underscores in its name
bool hasNoUnderscoresInName(FormalParameter parameter) =>
    parameter.name != null &&
    parameter.name!.lexeme.replaceAll('_', '').isNotEmpty;
