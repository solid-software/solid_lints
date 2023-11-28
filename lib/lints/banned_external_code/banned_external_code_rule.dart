import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as p;
import 'package:solid_lints/lints/banned_external_code/models/banned_external_code_entry_parameters.dart';
import 'package:solid_lints/lints/banned_external_code/models/banned_external_code_parameters.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';
import 'package:solid_lints/utils/node_utils.dart';
import 'package:solid_lints/utils/parameter_utils.dart';

/// A `banned_external_code` rule which
/// warns about usages of banned external code
class BannedExternalCodeRule
    extends SolidLintRule<BannedExternalCodeParameters> {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const String lintName = 'banned_external_code';

  BannedExternalCodeRule._(super.config);

  /// Creates a new instance of [BannedExternalCodeRule]
  /// based on the lint configuration.
  factory BannedExternalCodeRule.createRule(
    CustomLintConfigs configs,
  ) {
    final RuleConfig<BannedExternalCodeParameters> rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: BannedExternalCodeParameters.fromJson,
      problemMessage: (_) =>
          'Usage of this code has been discouraged by your project.',
    );

    return BannedExternalCodeRule._(rule);
  }

  @override
  Future<void> run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) async {
    final rootPath = (await resolver.getResolvedUnitResult())
        .session
        .analysisContext
        .contextRoot
        .root
        .path;
    final linter = _BannedCodeLinter(
      resolver: resolver,
      reporter: reporter,
      context: context,
      config: config,
    );

    final parameters = config.parameters;
    for (final entry in parameters.entries) {
      if (shouldSkipFile(
        includeGlobs: entry.includes,
        excludeGlobs: entry.excludes,
        path: resolver.path,
        rootPath: rootPath,
      )) {
        continue;
      }

      final entryCode = super.code.copyWith(
            errorSeverity: entry.severity ??
                parameters.severity ??
                super.code.errorSeverity,
            problemMessage: entry.reason,
          );

      switch (entry) {
        // all non null
        case BannedExternalCodeEntryParameters(
            :final id?,
            :final className?,
            :final source?
          ):
          linter.banIdFromClassFromSource(entryCode, id, className, source);

        // two non nulls
        case BannedExternalCodeEntryParameters(
            :final className?,
            :final source?
          ):
          linter.banClassFromSource(entryCode, className, source);
        case BannedExternalCodeEntryParameters(:final id?, :final className?):
          linter.banIdFromClass(entryCode, id, className);
        case BannedExternalCodeEntryParameters(:final id?, :final source?):
          linter.banIdFromSource(entryCode, id, source);

        // one non null
        case BannedExternalCodeEntryParameters(:final source?):
          linter.banSource(entryCode, source);
        case BannedExternalCodeEntryParameters(:final className?):
          linter.banClass(entryCode, className);
        case BannedExternalCodeEntryParameters(:final id?):
          linter.banId(entryCode, id);

        // all null
        case BannedExternalCodeEntryParameters():
          break;
      }
    }
  }
}

class _BannedCodeLinter {
  const _BannedCodeLinter({
    required this.resolver,
    required this.reporter,
    required this.context,
    required this.config,
  });

  final CustomLintResolver resolver;
  final ErrorReporter reporter;
  final CustomLintContext context;
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
