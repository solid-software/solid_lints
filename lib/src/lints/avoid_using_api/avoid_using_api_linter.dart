import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
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

      switch (node.staticElement) {
        case FunctionElement() || PropertyAccessorElement():
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
      final typeName = node.declaredElement?.type.element?.name;
      if (typeName != className) {
        return;
      }

      final sourcePath =
          node.declaredElement?.type.element?.librarySource?.uri.toString();
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
              staticType.element?.librarySource?.uri.toString() ??
                  node.sourceUrl;
          if (parentSourcePath == null ||
              !_matchesSource(parentSourcePath, source)) {
            return;
          }

          final parentTypeName = staticType.element?.name;
          if (parentTypeName != className) {
            return;
          }
        case SimpleIdentifier(:final staticElement?):
          final parentSourcePath =
              staticElement.librarySource?.uri.toString() ?? node.sourceUrl;
          if (parentSourcePath == null ||
              !_matchesSource(parentSourcePath, source)) {
            return;
          }
          final parentElementName = staticElement.name;
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
          final parentTypeName = staticType.element?.name;
          if (parentTypeName != className) {
            return;
          }

          reporter.atNode(
            node.parent ?? node,
            entryCode,
          );
        case SimpleIdentifier(:final staticElement?):
          final parentElementName = staticElement.name;
          if (parentElementName != className) {
            return;
          }

          reporter.atNode(
            node.parent ?? node,
            entryCode,
          );
        case NamedType(:final element?):
          final parentTypeName = element.name;
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
      if (methodName != identifier) {
        return;
      }

      final element = node.methodName.staticElement;
      if (element == null || element.enclosingElement3 is! ExtensionElement) {
        return;
      }

      final extensionElement = element.enclosingElement3! as ExtensionElement;

      if (extensionElement.name != className) {
        return;
      }

      final sourcePath = extensionElement.librarySource.uri.toString();
      if (!_matchesSource(sourcePath, source)) {
        return;
      }

      reporter.atNode(node.methodName, entryCode);
    });
  }
}
