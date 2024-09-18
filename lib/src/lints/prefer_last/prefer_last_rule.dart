import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/prefer_last/fixes/prefer_last_fix.dart';
import 'package:solid_lints/src/lints/prefer_last/visitors/prefer_last_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns about usage of `iterable[length - 1]` or
/// `iterable.elementAt(length - 1)` instead of `iterable.last`.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// final a = [1, 2, 3];
///
/// a[a.length - 1];           // LINT
/// a.elementAt(a.length - 1); // LINT
/// ```
///
/// #### GOOD:
///
/// ```dart
/// final a = [1, 2, 3];
///
/// a.last; // OK
/// ```
class PreferLastRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if iterable
  /// access can be simplified.
  static const lintName = 'prefer_last';

  PreferLastRule._(super.config);

  /// Creates a new instance of [PreferLastRule]
  /// based on the lint configuration.
  factory PreferLastRule.createRule(CustomLintConfigs configs) {
    final config = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) =>
          'Use last instead of accessing the last element by index.',
    );

    return PreferLastRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = PreferLastVisitor();
      node.accept(visitor);

      for (final element in visitor.expressions) {
        reporter.atNode(element, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [PreferLastFix()];
}
