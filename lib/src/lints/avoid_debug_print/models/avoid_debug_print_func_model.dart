import 'package:analyzer/dart/ast/ast.dart';

/// A class used to parse function expression
class AvoidDebugPrintFuncModel {
  /// Function name
  final String name;

  /// Function's source path
  final String sourcePath;

  /// A class used to parse function expression
  const AvoidDebugPrintFuncModel({
    required this.name,
    required this.sourcePath,
  });

  /// A constructor that parses identifier into [name] and [sourcePath]
  factory AvoidDebugPrintFuncModel.parseExpression(
    Identifier identifier,
  ) {
    switch (identifier) {
      case PrefixedIdentifier():
        final prefix = identifier.prefix.name;
        return AvoidDebugPrintFuncModel(
          name: identifier.name.replaceAll('$prefix.', ''),
          sourcePath:
              identifier.staticElement?.librarySource?.uri.toString() ?? '',
        );
      case SimpleIdentifier():
        return AvoidDebugPrintFuncModel(
          name: identifier.name,
          sourcePath:
              identifier.staticElement?.librarySource?.uri.toString() ?? '',
        );
      default:
        return AvoidDebugPrintFuncModel._empty();
    }
  }

  factory AvoidDebugPrintFuncModel._empty() {
    return const AvoidDebugPrintFuncModel(
      name: '',
      sourcePath: '',
    );
  }

  static const String _printPath = 'package:flutter/src/foundation/print.dart';

  static const String _debugPrint = 'debugPrint';

  /// Ehether the function has the same source library as debugPrint func
  bool get hasTheSameSource => _printPath == sourcePath;

  /// Ehether the function has the same name as debugPrint
  bool get hasSameName => _debugPrint == name;

  @override
  String toString() {
    return '$name, $sourcePath';
  }
}
