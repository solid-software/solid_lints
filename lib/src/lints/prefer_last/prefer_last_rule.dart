import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/prefer_last/fixes/prefer_last_fix.dart';
import 'package:solid_lints/src/lints/prefer_last/visitors/prefer_last_visitor.dart';
import 'package:solid_lints/src/models/rule_with_fixes.dart';
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
class PreferLastRule extends SolidLintRule implements RuleWithFixes {
  /// This lint rule represents the error if iterable
  /// access can be simplified.
  static const lintName = 'prefer_last';

  static const _code = LintCode(
    lintName,
    "Use last instead of accessing the last element by index.",
  );

  /// Creates a new instance of [PreferLastRule]
  PreferLastRule() : super(name: lintName, description: _code.problemMessage);

  @override
  LintCode get diagnosticCode => _code;

  @override
  FixesForCodes get fixesForCodes => const [MapEntry(_code, PreferLastFix.new)];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = PreferLastVisitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}
