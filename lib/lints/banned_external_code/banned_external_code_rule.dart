import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/banned_external_code/banned_external_code_linter.dart';
import 'package:solid_lints/lints/banned_external_code/models/banned_external_code_entry_parameters.dart';
import 'package:solid_lints/lints/banned_external_code/models/banned_external_code_parameters.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';
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
    final linter = BannedExternalCodeLinter(
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
