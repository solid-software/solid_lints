import 'package:analyzer/dart/ast/ast.dart';

/// A class used to parse function expression
class AvoidDebugPrintInReleaseDebugModel {
  /// Function name
  final String name;

  /// Function's source path
  final String sourcePath;

  /// A class used to parse function expression
  const AvoidDebugPrintInReleaseDebugModel({
    required this.name,
    required this.sourcePath,
  });

  /// A constructor that parses identifier into [name] and [sourcePath]
  factory AvoidDebugPrintInReleaseDebugModel.parseExpression(
    AstNode? identifier,
  ) {
    switch (identifier) {
      case PrefixedIdentifier():
        final prefix = identifier.prefix.name;
        return AvoidDebugPrintInReleaseDebugModel(
          name: identifier.name.replaceAll('$prefix.', ''),
          sourcePath:
              identifier.staticElement?.librarySource?.uri.toString() ?? '',
        );
      case SimpleIdentifier():
        return AvoidDebugPrintInReleaseDebugModel(
          name: identifier.name,
          sourcePath:
              identifier.staticElement?.librarySource?.uri.toString() ?? '',
        );
      default:
        return AvoidDebugPrintInReleaseDebugModel._empty();
    }
  }

  factory AvoidDebugPrintInReleaseDebugModel._empty() {
    return const AvoidDebugPrintInReleaseDebugModel(
      name: '',
      sourcePath: '',
    );
  }

  static const String _expectedPath =
      'package:flutter/src/foundation/constants.dart';

  static const String _kDebugMode = 'kDebugMode';

  /// Whether the function has the same source library as kDebugMode
  bool get hasTheSameSource => _expectedPath == sourcePath;

  /// Whether the function has the same name as kDebugMode
  bool get hasSameName => _kDebugMode == name;

  /// The complete check if the statement is the `kDebugMode` identifier.
  bool get isDebugMode => hasSameName && hasTheSameSource;

  @override
  String toString() {
    return '$name, $sourcePath';
  }
}
