import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/prefer_first/visitors/prefer_first_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns about usage of iterable[0] or iterable.elementAt(0) instead of
/// iterable.first.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// final a = [1, 2, 3];
///
/// a[0];           // LINT
/// a.elementAt(0); // LINT
/// ```
///
/// #### GOOD:
///
/// ```dart
/// final a = [1, 2, 3];
///
/// a.first; // OK
/// ```
class PreferFirstRule extends SolidLintRule {
  /// This lint rule represents the error if number of
  /// parameters reaches the maximum value.
  static const lintName = 'prefer_first';

  static const _code = LintCode(
    lintName,
    "Use first instead of accessing the element at zero index.",
  );

  @override
  LintCode get diagnosticCode => _code;

  /// Creates a new instance of [PreferFirstRule]
  PreferFirstRule() : super(name: lintName, description: _code.problemMessage);

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = PreferFirstVisitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}
