import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/avoid_using_api/avoid_using_api_linter.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_entry_parameters.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_parameters.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';
import 'package:solid_lints/src/utils/parameter_utils.dart';
import 'package:solid_lints/src/utils/path_utils.dart';

/// A `avoid_using_api` rule which
/// warns about usage of avoided APIs
///
///
/// ### Usage
///
/// External code can be "deprecated" when there is a better option available:
///
/// ```yaml
/// custom_lint:
///   rules:
///     - avoid_using_api:
///       severity: info
///       entries:
///         - class_name: Future
///           identifier: wait
///           source: dart:async
///           reason: "Future.wait should be avoided because it loses type
///                    safety for the results. Use a Record's `wait` method
///                    instead."
///           severity: warning
/// ```
///
/// Result:
///
/// ```dart
/// void main() async {
///   await Future.wait([...]); // LINT
///   await (...).wait; // OK
/// }
/// ```
///
/// ### Advanced Usage
///
/// Each entry also has `includes` and `excludes` parameters.
/// These paths utilize [Glob](https://pub.dev/packages/glob)
/// patterns to determine if a lint entry should be applied to a file.
///
/// For example, a lint to prevent usage of a domain-only package outside of the
/// domain folder:
///
/// ```yaml
/// custom_lint:
///   rules:
///     - avoid_using_api:
///       severity: info
///       entries:
///         - source: package:domain_models
///           excludes:
///             - "**/domain/**.dart"
///           reason: "domain_models is only intended to be used in the domain
///                    layer."
/// ```
///
/// Contributed by getBoolean (https://github.com/getBoolean).
class AvoidUsingApiRule extends SolidLintRule<AvoidUsingApiParameters> {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const String lintName = 'avoid_using_api';

  AvoidUsingApiRule._(super.config);

  /// Creates a new instance of [AvoidUsingApiRule]
  /// based on the lint configuration.
  factory AvoidUsingApiRule.createRule(
    CustomLintConfigs configs,
  ) {
    final RuleConfig<AvoidUsingApiParameters> rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidUsingApiParameters.fromJson,
      problemMessage: (_) =>
          'Usage of this code has been discouraged by your project.',
    );

    return AvoidUsingApiRule._(rule);
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
    final linter = AvoidUsingApiLinter(
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
        case AvoidUsingApiEntryParameters(:final source) when source == null:
          break;
        case AvoidUsingApiEntryParameters(
            :final identifier?,
            :final className?,
            :final source?
          ):
          linter.banIdFromClassFromSource(
            entryCode,
            identifier,
            className,
            source,
          );
        case AvoidUsingApiEntryParameters(:final className?, :final source?):
          linter.banClassFromSource(entryCode, className, source);
        case AvoidUsingApiEntryParameters(:final identifier?, :final source?):
          linter.banIdFromSource(entryCode, identifier, source);
        case AvoidUsingApiEntryParameters(:final source?):
          linter.banSource(entryCode, source);
        case AvoidUsingApiEntryParameters():
          break;
      }
    }
  }
}
