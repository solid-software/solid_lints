import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/double_literal_format/visitors/double_literal_format_visitor.dart';

/// A `double_literal_format` rule which
/// checks that double literals should begin with 0. instead of just .,
/// and should not end with a trailing 0.
///
/// {@template solid_lints.double_literal_format.example}
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// var a = 05.23, b = .16e+5, c = -0.250, d = -0.400e-5;
/// ```
///
/// #### GOOD:
///
/// ```dart
/// var a = 5.23, b = 0.16e+5, c = -0.25, d = -0.4e-5;
/// ```
/// {@endtemplate}
class DoubleLiteralFormatRule extends MultiAnalysisRule {
  /// This lint rule represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'double_literal_format';

  // Use different messages for different issues
  /// Reported when the double literal has a redundant leading 0
  ///
  /// ### Example
  ///
  /// #### BAD:
  ///
  /// ```dart
  /// var a = 05.23;
  /// ```
  ///
  /// #### GOOD:
  ///
  /// ```dart
  /// var a = 5.23;
  /// ```
  static const leadingZeroCode = LintCode(
    lintName,
    "Double literals shouldn't have redundant leading `0`.",
    correctionMessage: "Remove redundant leading `0`.",
    uniqueName: 'leadingZero',
  );

  /// Reported when the double literal has a leading decimal point
  /// without a zero before it.
  ///
  /// ### Example
  ///
  /// #### BAD:
  ///
  /// ```dart
  /// var a = .23;
  /// ```
  ///
  /// #### GOOD:
  ///
  /// ```dart
  /// var a = 0.23;
  /// ```
  static const leadingDecimalCode = LintCode(
    lintName,
    "Double literals shouldn't begin with the decimal point `.`.",
    correctionMessage: "Add missing leading `0`.",
    uniqueName: 'leadingDecimal',
  );

  /// Reported when the double literal has a redundant trailing 0.
  ///
  /// ### Example
  ///
  /// #### BAD:
  ///
  /// ```dart
  /// var a = 5.230;
  /// ```
  ///
  /// #### GOOD:
  ///
  /// ```dart
  /// var a = 5.23;
  /// ```
  static const trailingZeroCode = LintCode(
    lintName,
    "Double literals should not end with a trailing `0`.",
    correctionMessage: "Remove redundant trailing `0`.",
    uniqueName: 'trailingZero',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    leadingZeroCode,
    leadingDecimalCode,
    trailingZeroCode,
  ];

  /// Creates a new instance of [DoubleLiteralFormatRule]
  DoubleLiteralFormatRule()
    : super(
        name: lintName,
        description:
            'Double literals should begin with `0.` instead of just `.`, '
            'should not end with a trailing 0 and '
            'should not start with a leading 0',
      );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final visitor = DoubleLiteralFormatVisitor(this);
    registry.addDoubleLiteral(this, visitor);
  }
}
