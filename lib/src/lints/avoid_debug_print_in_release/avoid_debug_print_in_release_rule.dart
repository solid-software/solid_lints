import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_debug_print_in_release/visitors/avoid_debug_print_in_release_visitor.dart';

/// An `avoid_debug_print_in_release` rule which forbids calling or referencing
/// debugPrint function from flutter/foundation in release mode.
///
/// See more here: https://github.com/flutter/flutter/issues/147141
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// debugPrint(''); // LINT
/// var ref = debugPrint; // LINT
/// var ref2;
/// ref2 = debugPrint; // LINT
/// ```
///
/// #### GOOD:
///
/// ```dart
/// if (!kReleaseMode) {
///   debugPrint('');
/// }
/// ```
///
///

class AvoidDebugPrintInReleaseRule extends AnalysisRule {
  /// The name of the lint
  static const String lintName = 'avoid_debug_print_in_release';

  /// Lint code used for suppression and reporting.
  static const LintCode _code = LintCode(
    lintName,
    'Avoid debugPrint in release mode.',
    correctionMessage: 'Wrap in a kReleaseMode check or use a logging package.',
  );

  /// Creates an instance of [AvoidDebugPrintInReleaseRule].
  AvoidDebugPrintInReleaseRule()
      : super(name: lintName, description: 'Avoid debugPrint in release mode.');

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = AvoidDebugPrintInReleaseVisitor(this);
    registry.addMethodInvocation(this, visitor);
    registry.addSimpleIdentifier(this, visitor);
  }
}
