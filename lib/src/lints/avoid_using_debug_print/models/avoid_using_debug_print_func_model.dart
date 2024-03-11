import 'package:analyzer/dart/ast/ast.dart';

/// A class used to parse function expression
sealed class AvoidUsingDebugPrintFuncModel {
  /// Function name
  final String name;

  /// Function's source path
  final String sourcePath;

  const AvoidUsingDebugPrintFuncModel({
    required this.name,
    required this.sourcePath,
  });

  /// Sttic method that return whether the class supports given identifier
  static bool canParseIdentifier(Identifier identifier) {
    return identifier is SimpleIdentifier || identifier is PrefixedIdentifier;
  }

  factory AvoidUsingDebugPrintFuncModel.parseExpression(
    Identifier identifier,
  ) {
    if (identifier is PrefixedIdentifier) {
      final prefix = identifier.prefix.name;
      return AvoidUsingDebugPrintPrefixedFuncModel(
        name: identifier.name.replaceAll('$prefix.', ''),
        prefix: identifier.prefix.name,
        sourcePath:
            identifier.staticElement?.librarySource?.uri.toString() ?? '',
      );
    }

    if (identifier is SimpleIdentifier) {
      return AvoidUsingDebugPrintSimpleFuncModel(
        name: identifier.name,
        sourcePath:
            identifier.staticElement?.librarySource?.uri.toString() ?? '',
      );
    }

    return AvoidUsingDebugPrintUnsupportedFuncModel(
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

/// A class that represents function of unsupported type
final class AvoidUsingDebugPrintUnsupportedFuncModel
    extends AvoidUsingDebugPrintFuncModel {
  /// A class that represents function of unsupported type

  AvoidUsingDebugPrintUnsupportedFuncModel({
    required super.name,
    required super.sourcePath,
  });
}

/// A class that represents function of type [SimpleIdentifier]
final class AvoidUsingDebugPrintSimpleFuncModel
    extends AvoidUsingDebugPrintFuncModel {
  /// A class that represents function of type [SimpleIdentifier]
  AvoidUsingDebugPrintSimpleFuncModel({
    required super.name,
    required super.sourcePath,
  });
}

/// A class that represents function of type [PrefixedIdentifier]
final class AvoidUsingDebugPrintPrefixedFuncModel
    extends AvoidUsingDebugPrintFuncModel {
  /// A class that represents function of type [PrefixedIdentifier]
  AvoidUsingDebugPrintPrefixedFuncModel({
    required super.name,
    required super.sourcePath,
    required this.prefix,
  });

  /// A prefix before the function
  final String prefix;

  @override
  String toString() {
    return '$name, $sourcePath, $prefix';
  }
}
