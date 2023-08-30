import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `double-literal-format` rule which
/// checks that double literals should begin with 0. instead of just .,
/// and should not end with a trailing 0.
/// BAD:
/// var a = 05.23, b = .16e+5, c = -0.250, d = -0.400e-5;
/// GOOD:
/// var a = 5.23, b = 0.16e+5, c = -0.25, d = -0.4e-5;
class DoubleLiteralFormatRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use global state.
  static const lintName = 'double-literal-format';

  DoubleLiteralFormatRule._(super.config);

  /// Creates a new instance of [DoubleLiteralFormatRule]
  /// based on the lint configuration.
  factory DoubleLiteralFormatRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => ''
          'Double literals should start with `0.` instead of `.`'
          'Double literals should not end with a trailing `0`',
    );

    return DoubleLiteralFormatRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // TODO: implement run
    context.registry.addDoubleLiteral((node) {
      print('CHECK double rule $node | ${node.literal}');
      // reporter.reportErrorForNode(code, node);
    });
  }
}
