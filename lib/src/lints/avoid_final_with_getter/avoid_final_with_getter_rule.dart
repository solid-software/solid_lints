import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/fixes/avoid_final_with_getter_fix.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/visitors/avoid_final_with_getter_visitor.dart';
import 'package:solid_lints/src/models/rule_with_fixes.dart';

/// Avoid using final private fields with getters.
///
/// Final private variables used in a pair with a getter
/// must be changed to a final public type without a getter
/// because it is the same as a public field.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// class MyClass {
///   final int _myField = 0;
///
///   int get myField => _myField;
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// class MyClass {
///   final int myField = 0;
/// }
/// ```
///
class AvoidFinalWithGetterRule extends AnalysisRule implements RuleWithFixes {
  /// This lint rule represents
  /// the error whether we use final private fields with getters.
  static const lintName = 'avoid_final_with_getter';

  /// The code to report for a violation
  static const LintCode code = LintCode(
    lintName,
    'Avoid final private fields with getters.',
    correctionMessage: 'Remove the getter and make the field public.',
  );

  /// Creates a new instance of [AvoidFinalWithGetterRule]
  AvoidFinalWithGetterRule()
    : super(name: lintName, description: code.problemMessage);

  @override
  LintCode get diagnosticCode => code;

  @override
  FixesForCodes get fixesForCodes => const [
    MapEntry(code, AvoidFinalWithGetterFix.new),
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = AvoidFinalWithGetterVisitor(this);

    registry.addCompilationUnit(this, visitor);
  }
}
