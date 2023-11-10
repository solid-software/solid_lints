import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/prefer_first/prefer_first_fix.dart';
import 'package:solid_lints/lints/prefer_first/prefer_first_visitor.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `prefer_first` rule which warns about
/// usage of iterable[0] or iterable.elementAt(0)
class PreferFirstRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'prefer_first';

  PreferFirstRule._(super.config);

  /// Creates a new instance of [PreferFirstRule]
  /// based on the lint configuration.
  factory PreferFirstRule.createRule(CustomLintConfigs configs) {
    final config = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) =>
          'Use first instead of accessing the element at zero index.',
    );

    return PreferFirstRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final visitor = PreferFirstVisitor();
      node.accept(visitor);

      for (final element in visitor.expressions) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }

  @override
  List<Fix> getFixes() => [PreferFirstFix()];
}
