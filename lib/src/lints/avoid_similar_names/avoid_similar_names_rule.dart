import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/visitors/avoid_similar_names_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Avoid similar names
///
/// Warns about variables or parameters that have confusingly similar names
/// within the same function scope (e.g., using numeric suffixes or
/// single-letter modifiers like `someClass1` and `someClass2`).
///
/// This encourages using descriptive, distinct names to improve code
/// readability and prevent logical errors caused by mixing up variables.
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// void test(SomeClass someClass1, SomeClass someClass2) { // LINT
///   final tempA = 'a'; // LINT
///   final tempB = 'b'; // LINT
/// }
/// ```
///
/// #### GOOD:
///
/// ```dart
/// void test(SomeClass first, SomeClass second) {
///   final that = 'a';
///   final other = 'b';
/// }
/// ```
class AvoidSimilarNamesRule extends SolidLintRule<void> {
  /// The name of this lint rule.
  static const lintName = 'avoid_similar_names';

  static const _code = LintCode(
    lintName,
    'Avoid using similar names.',
    correctionMessage: 'Use more descriptive names.',
  );

  /// Creates an instance of [AvoidSimilarNamesRule].
  AvoidSimilarNamesRule()
    : super(
        name: lintName,
        description: 'Warns about variables or parameters with similar names.',
      );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = AvoidSimilarNamesVisitor(this);

    registry.addMethodDeclaration(this, visitor);
    registry.addConstructorDeclaration(this, visitor);
    registry.addFunctionDeclaration(this, visitor);
  }
}
