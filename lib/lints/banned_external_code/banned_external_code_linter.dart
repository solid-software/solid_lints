import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/lints/banned_external_code/banned_external_code_rule.dart';
import 'package:solid_lints/lints/banned_external_code/models/banned_external_code_parameters.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/utils/node_utils.dart';

/// Linter for [BannedExternalCodeRule]
class BannedExternalCodeLinter {
  /// Linter for [BannedExternalCodeRule]
  const BannedExternalCodeLinter({
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
  final RuleConfig<BannedExternalCodeParameters?> config;

  bool _matchesSource(String? parentSourcePath, String sourceToMatch) {
    if (parentSourcePath == null) {
      return false;
    }

    final libraryPathParts = parentSourcePath.split('/');
    final libraryName = libraryPathParts.first;

    final sourceLibraryPathParts = sourceToMatch.split('/');
    final sourceLibraryName = sourceLibraryPathParts.first;

    final matchesLibraryName = libraryName == sourceLibraryName;
    final shouldLintFileFromSource = sourceLibraryPathParts.length > 1;
    if (shouldLintFileFromSource) {
      final sourceFile = (sourceLibraryPathParts..removeAt(0)).join('/');
      final libraryFile = (libraryPathParts..removeAt(0)).join('/');

      final matchesFile = p.equals(sourceFile, libraryFile);
      return matchesLibraryName && matchesFile;
    }

    return matchesLibraryName;
  }

  void banId(
    LintCode entryCode,
    String id,
  ) {
    banIdFromSource(entryCode, id);
  }

  void banClass(
    LintCode entryCode,
    String className,
  ) {
    banClassFromSource(entryCode, className);
  }

  void banSource(LintCode entryCode, String package) {
    context.registry.addSimpleIdentifier((node) {
      final parentSourceName = node.sourceUrl;
      if (!_matchesSource(parentSourceName, package)) {
        return;
      }

      if (node.parent is ConstructorDeclaration) {
        return;
      }

      reporter.reportErrorForNode(entryCode, node);
    });

    context.registry.addNamedType((node) {
      final parentSourceName = node.sourceUrl;
      if (!_matchesSource(parentSourceName, package)) {
        return;
      }

      reporter.reportErrorForNode(entryCode, node);
    });
  }

  void banIdFromSource(LintCode entryCode, String id, [String? source]) {
    // only matches globals
    context.registry.addSimpleIdentifier((node) {
      final name = node.name;
      if (name != id) {
        return;
      }

      final parentSourceName = node.sourceUrl;
      if (source != null && !_matchesSource(parentSourceName, source)) {
        return;
      }

      if (node.parent is ConstructorDeclaration) {
        return;
      }

      switch (node.staticElement) {
        case FunctionElement() || PropertyAccessorElement():
          reporter.reportErrorForNode(entryCode, node);
      }
    });
  }

  void banIdFromClass(LintCode entryCode, String id, String className) {
    banIdFromClassFromSource(entryCode, id, className);
  }

  void banClassFromSource(
    LintCode entryCode,
    String className, [
    String? source,
  ]) {
    context.registry.addSimpleIdentifier((node) {
      final parentSourceName = node.sourceUrl;
      if (source != null && !_matchesSource(parentSourceName, source)) {
        return;
      }

      final parent = node.parent;
      final entityBeforeNode =
          parent!.childEntities.firstWhere((element) => element != node);
      switch (entityBeforeNode) {
        case InstanceCreationExpression(:final staticType?):
        case SimpleIdentifier(:final staticType?):
          final parentTypeName = staticType.element?.name;
          if (parentTypeName != className) {
            return;
          }
        case SimpleIdentifier(:final staticElement?):
          final parentElementName = staticElement.name;
          if (parentElementName != className) {
            return;
          }
        default:
          return;
      }

      reporter.reportErrorForNode(entryCode, parent);
    });

    context.registry.addNamedType((node) {
      final nodeTypeName = node.name2.lexeme;
      if (nodeTypeName != className) {
        return;
      }

      final parentSourceName = node.sourceUrl;
      if (source != null && !_matchesSource(parentSourceName, source)) {
        return;
      }

      reporter.reportErrorForNode(
        entryCode,
        node.parent?.parent ?? node.parent ?? node,
      );
    });
  }

  void banIdFromClassFromSource(
    LintCode entryCode,
    String id,
    String className, [
    String? source,
  ]) {
    context.registry.addSimpleIdentifier((node) {
      final name = node.name;
      if (name != id) {
        return;
      }

      final parentSourceName = node.sourceUrl;
      if (source != null && !_matchesSource(parentSourceName, source)) {
        return;
      }

      final parent = node.parent;
      final entityBeforeNode =
          parent!.childEntities.firstWhere((element) => element != node);
      switch (entityBeforeNode) {
        case InstanceCreationExpression(:final staticType?):
        case SimpleIdentifier(:final staticType?):
          final parentTypeName = staticType.element?.name;
          if (parentTypeName != className) {
            return;
          }

          reporter.reportErrorForNode(entryCode, node.parent ?? node);
        case SimpleIdentifier(:final staticElement?):
          final parentElementName = staticElement.name;
          if (parentElementName != className) {
            return;
          }

          reporter.reportErrorForNode(entryCode, node.parent ?? node);
        case NamedType(:final element?):
          final parentTypeName = element.name;
          if (parentTypeName != className) {
            return;
          }

          reporter.reportErrorForNode(
            entryCode,
            node.parent?.parent ?? node.parent ?? node,
          );
      }
    });
  }
}
