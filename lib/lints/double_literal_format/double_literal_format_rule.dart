import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

part 'double_literal_format_fix.dart';

part 'double_literal_format_utils.dart';

/// A `double_literal_format` rule which
/// checks that double literals should begin with 0. instead of just .,
/// and should not end with a trailing 0.
///
/// ## Example
///
/// ### BAD:
///
/// ```dart
/// var a = 05.23, b = .16e+5, c = -0.250, d = -0.400e-5;
/// ```
///
/// ### GOOD:
///
/// ```dart
/// var a = 5.23, b = 0.16e+5, c = -0.25, d = -0.4e-5;
/// ```
class DoubleLiteralFormatRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'double_literal_format';

  // Use different messages for different issues
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use double literals with a redundant leading 0.
  static const _leadingZeroCode = LintCode(
    name: lintName,
    problemMessage: "Double literals shouldn't have redundant leading `0`.",
    correctionMessage: "Remove redundant leading `0`.",
  );

  /// The [LintCode] of this lint rule that represents
  /// the error whether we use double literals with a leading decimal point.
  static const _leadingDecimalCode = LintCode(
    name: lintName,
    problemMessage:
        "Double literals shouldn't begin with the decimal point `.`.",
    correctionMessage: "Add missing leading `0`.",
  );

  /// The [LintCode] of this lint rule that represents
  /// the error whether we use double literals with a trailing 0.
  static const _trailingZeroCode = LintCode(
    name: lintName,
    problemMessage: "Double literals should not end with a trailing `0`.",
    correctionMessage: "Remove redundant trailing `0`.",
  );

  DoubleLiteralFormatRule._(super.config);

  /// Creates a new instance of [DoubleLiteralFormatRule]
  /// based on the lint configuration.
  factory DoubleLiteralFormatRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => 'Double literal formatting issue',
    );

    return DoubleLiteralFormatRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDoubleLiteral((node) {
      final lexeme = node.literal.lexeme;

      if (lexeme.hasLeadingZero) {
        reporter.reportErrorForNode(_leadingZeroCode, node);
        return;
      }
      if (lexeme.hasLeadingDecimalPoint) {
        reporter.reportErrorForNode(_leadingDecimalCode, node);
        return;
      }
      if (lexeme.hasTrailingZero) {
        reporter.reportErrorForNode(_trailingZeroCode, node);
        return;
      }
    });
  }

  @override
  List<Fix> getFixes() => [_DoubleLiteralFormatFix()];
}
