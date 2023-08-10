import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A global state rule which forbids using variables
/// that can be globally modified.
class AvoidGlobalStateRule extends DartLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use global state.
  static const lintName = 'avoid_global_state';

  /// Creates a new instance of [AvoidGlobalStateRule].
  const AvoidGlobalStateRule({required super.code});

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      final isPrivate = node.declaredElement?.isPrivate ?? false;

      if (!isPrivate && !node.isFinal && !node.isConst) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
