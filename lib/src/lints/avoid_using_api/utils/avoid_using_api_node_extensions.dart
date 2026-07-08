import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_entry_parameters.dart';
import 'package:solid_lints/src/utils/node_utils.dart';
import 'package:solid_lints/src/utils/path_utils.dart';

const String _defaultConstructorIdentifier = '()';

/// Extension on [SimpleIdentifier] to check if it matches avoided API
/// configurations.
extension AvoidUsingApiSimpleIdentifierExtension on SimpleIdentifier {
  /// Returns `true` if this identifier matches the given [entry] parameters.
  bool matches(AvoidUsingApiEntryParameters entry) {
    final source = entry.source;
    if (source == null) return false;

    return switch ((entry.className, entry.identifier, entry.namedParameter)) {
      (final String _, final String _, null) =>
        _matchesIdFromClassFromSource(entry),
      (final String _, null, null) =>
        _matchesClassFromSource(entry),
      (null, final String _, null) =>
        _matchesIdFromSource(entry),
      (null, null, null) =>
        _matchesSource(entry),
      _ => false,
    };
  }

  bool _matchesClassFromSource(AvoidUsingApiEntryParameters entry) {
    final className = entry.className;
    final source = entry.source;
    final parent = this.parent;
    final element = this.element;
    if (className == null ||
        source == null ||
        parent == null ||
        element == null ||
        parent is ConstructorDeclaration ||
        !element.isMemberOrClass(
          className: className,
          source: source,
        )) {
      return false;
    }

    return true;
  }

  bool _matchesIdFromClassFromSource(AvoidUsingApiEntryParameters entry) {
    final identifier = entry.identifier;
    final className = entry.className;
    final source = entry.source;
    final parent = this.parent;
    final element = this.element;
    if (identifier == null ||
        className == null ||
        source == null ||
        element == null ||
        identifier == _defaultConstructorIdentifier ||
        name != identifier ||
        parent == null ||
        parent is ConstructorDeclaration ||
        !element.isMemberOrClass(
          className: className,
          source: source,
        )) {
      return false;
    }

    return true;
  }

  bool _matchesSource(AvoidUsingApiEntryParameters entry) {
    final source = entry.source;
    if (source == null ||
        !matchesSource(sourceUrl, source) ||
        parent is ConstructorDeclaration) {
      return false;
    }

    return true;
  }

  bool _matchesIdFromSource(AvoidUsingApiEntryParameters entry) {
    final identifier = entry.identifier;
    final source = entry.source;
    if (identifier == null ||
        source == null ||
        name != identifier ||
        !matchesSource(sourceUrl, source) ||
        parent is ConstructorDeclaration) {
      return false;
    }

    final el = element;
    return el is LocalFunctionElement ||
        el is TopLevelFunctionElement ||
        el is PropertyAccessorElement;
  }
}

/// Extension on [NamedType] to check if it matches avoided API configurations.
extension AvoidUsingApiNamedTypeExtension on NamedType {
  /// Returns `true` if this named type matches the given [entry] parameters.
  bool matches(AvoidUsingApiEntryParameters entry) {
    final source = entry.source;
    if (source == null ||
        entry.identifier != null ||
        !matchesSource(sourceUrl, source) ||
        (entry.className != null && name.lexeme != entry.className)) {
      return false;
    }

    return true;
  }
}

/// Extension on [VariableDeclaration] to check if it matches avoided API
/// configurations.
extension AvoidUsingApiVariableDeclarationExtension on VariableDeclaration {
  /// Returns `true` if this variable declaration matches the given [entry]
  /// parameters.
  bool matches(AvoidUsingApiEntryParameters entry) {
    final source = entry.source;
    final className = entry.className;
    final typeElement = declaredType?.element;
    if (source == null ||
        entry.identifier != null ||
        className == null ||
        typeElement?.name != className ||
        !matchesSource(typeElement?.libraryUri, source)) {
      return false;
    }

    return true;
  }
}

/// Extension on [InstanceCreationExpression] to check if it matches avoided API
/// configurations.
extension AvoidUsingApiInstanceCreationExtension on InstanceCreationExpression {
  /// Returns `true` if this instance creation matches the given [entry]
  /// parameters.
  bool matches(AvoidUsingApiEntryParameters entry) {
    final source = entry.source;
    if (source == null) return false;

    final className = entry.className;
    final identifier = entry.identifier;
    final namedParameter = entry.namedParameter;

    switch ((className, identifier, namedParameter)) {
      case (
        final String className,
        final String identifier,
        final String namedParameter,
      ):
        // banUsageWithSpecificNamedParameter
        String? expectedConstructorName;
        if (identifier != _defaultConstructorIdentifier) {
          expectedConstructorName = identifier;
        }

        final actualClassName = constructorName.type.name.lexeme;
        return actualClassName == className &&
            constructorName.name?.name == expectedConstructorName &&
            argumentList.containsNamed(namedParameter) &&
            matchesSource(
              constructorName.type.element?.libraryUri,
              source,
            );

      case (
        final String className,
        _defaultConstructorIdentifier,
        null,
      ):
        // banIdFromClassFromSource for default constructor
        final actualConstructorName = constructorName.type.name.lexeme;
        return actualConstructorName == className &&
            constructorName.name == null &&
            matchesSource(
              constructorName.type.element?.libraryUri,
              source,
            );
      default:
        return false;
    }
  }
}

/// Extension on [MethodInvocation] to check if it matches avoided API
/// configurations.
extension AvoidUsingApiMethodInvocationExtension on MethodInvocation {
  /// Returns `true` if this method invocation matches the given [entry]
  /// parameters.
  bool matches(AvoidUsingApiEntryParameters entry) {
    final AvoidUsingApiEntryParameters(:source, :className, :namedParameter) =
        entry;

    final enclosingElement = methodName.element?.enclosingElement;

    if (source == null ||
        className == null ||
        namedParameter == null ||
        methodName.name != entry.identifier ||
        enclosingElement == null ||
        enclosingElement.name != className ||
        !argumentList.containsNamed(namedParameter) ||
        !matchesSource(enclosingElement.libraryUri, source)) {
      return false;
    }

    return true;
  }
}
