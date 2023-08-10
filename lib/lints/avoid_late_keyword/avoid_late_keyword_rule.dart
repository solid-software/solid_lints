import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A `late` keyword rule which forbids using it to avoid runtime exceptions.
class AvoidLateKeywordRule extends DartLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use `late` keyword.
  static const lintName = 'avoid_late_keyword';

  /// Creates a new instance of [AvoidLateKeywordRule].
  const AvoidLateKeywordRule({required super.code});

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      if (node.declaredElement?.isLate ?? false) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
