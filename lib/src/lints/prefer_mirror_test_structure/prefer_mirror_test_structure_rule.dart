import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/prefer_mirror_test_structure/visitors/prefer_mirror_test_structure_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns when the test file folder structure does not mirror the 'lib/' folder
/// structure of the imported implementation file.
///
/// Keeping the same folder structure for your tests makes it easier to locate
/// test files and allows using IDE commands such as 'Go to Test/Implementation
/// File'.
///
/// This rule highlights test files that import implementation files with the
/// same name (without the `_test` suffix) when their relative directory path in
/// `test/` does not match the relative directory path in `lib/`.
///
/// ### Example
///
/// #### BAD:
///
/// File: `test/auth_service_test.dart`
///
/// ```dart
/// import 'package:my_app/src/services/auth_service.dart'; // LINT
/// ```
///
/// #### GOOD:
///
/// File: `test/src/services/auth_service_test.dart`
///
/// ```dart
/// import 'package:my_app/src/services/auth_service.dart'; // OK
/// ```
///
class PreferMirrorTestStructureRule extends SolidLintRule<void> {
  /// Name of the lint.
  static const lintName = 'prefer_mirror_test_structure';

  static const _code = LintCode(
    lintName,
    "The test file folder structure does not mirror the 'lib/' folder "
    'structure.',
    correctionMessage: "Move the test file to '{0}'.",
  );

  /// Creates an instance of [PreferMirrorTestStructureRule].
  PreferMirrorTestStructureRule()
    : super(
        name: lintName,
        description:
            'Warns when the test file folder structure does not mirror the '
            "'lib/' folder structure.",
      );

  @override
  DiagnosticCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final visitor = PreferMirrorTestStructureVisitor(
      rule: this,
      context: context,
    );

    registry.addCompilationUnit(this, visitor);
  }
}
