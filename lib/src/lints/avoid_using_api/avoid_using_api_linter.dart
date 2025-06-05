import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/src/lints/avoid_using_api/avoid_using_api_rule.dart';
import 'package:solid_lints/src/lints/avoid_using_api/avoid_using_api_utils.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_parameters.dart';
import 'package:solid_lints/src/models/rule_config.dart';

/// Linter for [AvoidUsingApiRule]
class AvoidUsingApiLinter {
  /// Linter for [AvoidUsingApiRule]
  const AvoidUsingApiLinter({
    required this.resolver,
    required this.reporter,
    required this.context,
    required this.config,
  });

  /// The identifier for the default constructor
  static const String defaultConstructorIdentifier = '()';

  /// Access to the resolver for this lint context
  final CustomLintResolver resolver;

  /// The error reporter to create lints
  final ErrorReporter reporter;

  /// The current lint context
  final CustomLintContext context;

  /// The configuration parameters for the lint
  final RuleConfig<AvoidUsingApiParameters?> config;

  bool _matchesSource(String parentSourcePath, String sourceToMatch) {
    final Uri parentUri = p.toUri(parentSourcePath);
    final Uri sourceUri = p.toUri(sourceToMatch);

    final libraryName = parentUri.pathSegments.first;
    final sourceLibraryName = sourceUri.pathSegments.first;

    final matchesLibraryName = libraryName == sourceLibraryName;
    final shouldLintFileFromSource = sourceUri.pathSegments.length > 1;
    if (shouldLintFileFromSource) {
      final sourceFile = sourceUri.pathSegments.sublist(1).join('/');
      final libraryFile = parentUri.pathSegments.sublist(1).join('/');

      final matchesFile = p.equals(sourceFile, libraryFile);
      return matchesLibraryName && matchesFile;
    }

    return matchesLibraryName;
  }

  /// Lints usages of a given source
  void banSource(LintCode entryCode, String source) {
    context.registry.addSimpleIdentifier((node) {
      final sourcePath = node.sourceUrl;
      if (sourcePath == null || !_matchesSource(sourcePath, source)) {
        return;
      }

      if (node.parent is ConstructorDeclaration) {
        return;
      }

      reporter.atNode(node, entryCode);
    });

    context.registry.addNamedType((node) {
      final sourceName = node.sourceUrl;
      if (sourceName == null || !_matchesSource(sourceName, source)) {
        return;
      }

      reporter.atNode(node, entryCode);
    });
  }

  /// Lints usages of a global variable or function from a given source
  void banIdFromSource(LintCode entryCode, String identifier, String source) {
    // only matches globals
    context.registry.addSimpleIdentifier((node) {
      final name = node.name;
      if (name != identifier) {
        return;
      }

      final sourcePath = node.sourceUrl;
      if (sourcePath == null || !_matchesSource(sourcePath, source)) {
        return;
      }

      if (node.parent is ConstructorDeclaration) {
        return;
      }

      switch (node.element) {
        case LocalFunctionElement() ||
              TopLevelFunctionElement() ||
              PropertyAccessorElement2():
          reporter.atNode(node, entryCode);
      }
    });
  }

  /// Lints usages of a class and its members from a given source
  void banClassFromSource(
    LintCode entryCode,
    String className,
    String source,
  ) {
    context.registry.addVariableDeclaration((node) {
      final typeName = node.declaredElement2?.type.element3?.name3;
      if (typeName != className) {
        return;
      }

      final sourcePath =
          node.declaredElement2?.type.element3?.library2?.uri.toString();
      if (sourcePath == null || !_matchesSource(sourcePath, source)) {
        return;
      }
      reporter.atNode(node, entryCode);
    });

    context.registry.addSimpleIdentifier((node) {
      final parent = node.parent;
      if (parent == null) {
        return;
      }

      if (parent is ConstructorDeclaration) {
        return;
      }

      final entityBeforeNode = parent.childEntities.firstOrNull;
      switch (entityBeforeNode) {
        case InstanceCreationExpression(:final staticType?):
        case SimpleIdentifier(:final staticType?):
          final parentSourcePath =
              staticType.element3?.library2?.uri.toString() ?? node.sourceUrl;
          if (parentSourcePath == null ||
              !_matchesSource(parentSourcePath, source)) {
            return;
          }

          final parentTypeName = staticType.element3?.name3;
          if (parentTypeName != className) {
            return;
          }
        case SimpleIdentifier(:final element?):
          final parentSourcePath =
              element.library2?.uri.toString() ?? node.sourceUrl;
          if (parentSourcePath == null ||
              !_matchesSource(parentSourcePath, source)) {
            return;
          }
          final parentElementName = element.name3;
          if (parentElementName != className) {
            return;
          }
        default:
          return;
      }

      reporter.atNode(parent, entryCode);
    });

    context.registry.addNamedType((node) {
      final nodeTypeName = node.name2.lexeme;
      if (nodeTypeName != className) {
        return;
      }

      final sourcePath = node.sourceUrl;
      if (sourcePath == null || !_matchesSource(sourcePath, source)) {
        return;
      }

      reporter.atNode(
        node.parent?.parent ?? node.parent ?? node,
        entryCode,
      );
    });
  }

  /// Lints usages of a class member from a given source
  void banIdFromClassFromSource(
    LintCode entryCode,
    String identifier,
    String className,
    String source,
  ) {
    if (identifier == defaultConstructorIdentifier) {
      _banDefaultConstructor(className, source, entryCode);
      return;
    }

    context.registry.addSimpleIdentifier((node) {
      final name = node.name;
      if (name != identifier) {
        return;
      }

      final sourcePath = node.sourceUrl;
      if (sourcePath == null || !_matchesSource(sourcePath, source)) {
        return;
      }

      final parent = node.parent;
      if (parent == null) {
        return;
      }

      if (parent is ConstructorDeclaration) {
        return;
      }

      final entityBeforeNode = parent.childEntities.firstOrNull;
      switch (entityBeforeNode) {
        case InstanceCreationExpression(:final staticType?):
        case SimpleIdentifier(:final staticType?):
          final parentTypeName = staticType.element3?.name3;
          if (parentTypeName != className) {
            return;
          }

          reporter.atNode(
            node.parent ?? node,
            entryCode,
          );
        case SimpleIdentifier(:final element?):
          final parentElementName = element.name3;
          if (parentElementName != className) {
            return;
          }

          reporter.atNode(
            node.parent ?? node,
            entryCode,
          );
        case NamedType(:final element2?):
          final parentTypeName = element2.name3;
          if (parentTypeName != className) {
            return;
          }

          reporter.atNode(
            node.parent?.parent ?? node.parent ?? node,
            entryCode,
          );
      }
    });

    context.registry.addMethodInvocation((node) {
      final methodName = node.methodName.name;
      if (methodName != identifier) return;

      final enclosingElement = node.methodName.element?.enclosingElement2;
      if (enclosingElement is! ExtensionElement2 ||
          enclosingElement.name3 != className) {
        return;
      }

      final sourcePath = enclosingElement.library2.uri.toString();
      if (!_matchesSource(sourcePath, source)) {
        return;
      }

      reporter.atNode(node.methodName, entryCode);
    });

    context.registry.addPrefixedIdentifier((node) {
      final propertyName = node.identifier.name;
      if (propertyName != identifier) return;

      final enclosingElement = node.identifier.element?.enclosingElement2;
      if (enclosingElement is! ExtensionElement2 ||
          enclosingElement.name3 != className) {
        return;
      }

      final sourcePath = enclosingElement.library2.uri.toString();
      if (!_matchesSource(sourcePath, source)) return;

      reporter.atNode(node.identifier, entryCode);
    });
  }

  void _banDefaultConstructor(
    String className,
    String source,
    LintCode entryCode,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final constructorName = node.constructorName.type.name2.lexeme;
      if (constructorName != className || node.constructorName.name != null) {
        return;
      }

      final sourcePath =
          node.constructorName.type.element2?.library2?.uri.toString();
      if (sourcePath == null || !_matchesSource(sourcePath, source)) {
        return;
      }

      reporter.atNode(node, entryCode);
    });
  }

  /// Lints usages of a named parameter from a given source
  void banUsageWithSpecificNamedParameter(
    LintCode entryCode,
    String identifier,
    String namedParameter,
    String className,
    String source,
  ) {
    context.registry.addMethodInvocation((node) {
      final methodName = node.methodName.name;
      if (methodName != identifier) return;

      final enclosingElement = node.methodName.element?.enclosingElement2;
      if (enclosingElement == null || enclosingElement.name3 != className) {
        return;
      }

      if (!_hasNamedParameter(node.argumentList, namedParameter)) {
        return;
      }

      final libSource = enclosingElement.library2;
      if (libSource == null) {
        return;
      }

      final sourcePath = libSource.uri.toString();
      if (!_matchesSource(sourcePath, source)) {
        return;
      }

      reporter.atNode(node.methodName, entryCode);
    });

    context.registry.addInstanceCreationExpression((node) {
      final String? expectedConstructorName;
      if (identifier == defaultConstructorIdentifier) {
        expectedConstructorName = null;
      } else {
        expectedConstructorName = identifier;
      }

      final actualClassName = node.constructorName.type.name2.lexeme;
      if (actualClassName != className) {
        return;
      }

      if (node.constructorName.name?.name != expectedConstructorName) {
        return;
      }

      if (!_hasNamedParameter(node.argumentList, namedParameter)) {
        return;
      }

      final sourcePath =
          node.constructorName.type.element2?.library2?.uri.toString();
      if (sourcePath == null || !_matchesSource(sourcePath, source)) {
        return;
      }

      reporter.atNode(node, entryCode);
    });
  }

  bool _hasNamedParameter(ArgumentList argumentList, String namedParameter) =>
      argumentList.arguments.any(
        (arg) =>
            arg is NamedExpression && arg.name.label.name == namedParameter,
      );
}
