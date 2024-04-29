import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// A class used to parse function expression
class AvoidDebugPrintInReleaseCheckModel {
  /// Wheather the statement is prefixed with `!`
  final bool negated;

  /// Function name
  final String name;

  /// Function's source path
  final String sourcePath;

  /// A class used to parse function expression
  const AvoidDebugPrintInReleaseCheckModel({
    required this.negated,
    required this.name,
    required this.sourcePath,
  });

  /// A constructor that parses identifier into [name] and [sourcePath]
  factory AvoidDebugPrintInReleaseCheckModel.parseExpression(
    Expression? expression,
  ) {
    switch (expression?.childEntities.toList()) {
      case [
          final Token token,
          final Identifier identifier,
        ]:
        return AvoidDebugPrintInReleaseCheckModel._parseIdentifier(
          identifier: identifier,
          negated: token.type == TokenType.BANG,
        );
      case [final Identifier identifier]:
        return AvoidDebugPrintInReleaseCheckModel._parseIdentifier(
          identifier: identifier,
          negated: false,
        );
      default:
        return AvoidDebugPrintInReleaseCheckModel._empty();
    }
  }

  factory AvoidDebugPrintInReleaseCheckModel._empty() {
    return const AvoidDebugPrintInReleaseCheckModel(
      negated: false,
      name: '',
      sourcePath: '',
    );
  }

  static const String _expectedPath =
      'package:flutter/src/foundation/constants.dart';

  static const String _kReleaseMode = 'kReleaseMode';

  /// Whether the expression has the same source library as kDebugMode
  bool get hasTheSameSource => _expectedPath == sourcePath;

  /// Whether the expression has the same name as kReleaseMode
  bool get hasSameName => _kReleaseMode == name;

  /// Whether the expression checks ifthe mode is not release.
  bool get isNotRelease => negated && hasSameName && hasTheSameSource;

  @override
  String toString() {
    return '$name, $sourcePath';
  }

  factory AvoidDebugPrintInReleaseCheckModel._parseIdentifier({
    required Identifier identifier,
    required bool negated,
  }) {
    switch (identifier) {
      case PrefixedIdentifier():
        final prefix = identifier.prefix.name;
        return AvoidDebugPrintInReleaseCheckModel(
          negated: negated,
          name: identifier.name.replaceAll('$prefix.', ''),
          sourcePath:
              identifier.staticElement?.librarySource?.uri.toString() ?? '',
        );
      case SimpleIdentifier():
        return AvoidDebugPrintInReleaseCheckModel(
          negated: negated,
          name: identifier.name,
          sourcePath:
              identifier.staticElement?.librarySource?.uri.toString() ?? '',
        );
      default:
        return AvoidDebugPrintInReleaseCheckModel._empty();
    }
  }
}
