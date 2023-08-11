import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/utils/types_utils.dart';

/// A rule which forbids returning widgets from functions and methods.
class AvoidReturningWidgetsRule extends DartLintRule {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we return a widget.
  static const lintName = 'avoid_returning_widgets';

  /// Creates a new instance of [AvoidReturningWidgetsRule].
  const AvoidReturningWidgetsRule({required super.code});

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      final bool isWidgetReturned;
      if (node is FunctionDeclaration) {
        final returnType = node.returnType?.type;
        isWidgetReturned = returnType != null && hasWidgetType(returnType);
      } else if (node is MethodDeclaration) {
        // `build` methods return widgets by nature
        if (node.declaredElement?.name == "build") {
          return;
        }

        // `FunctionDeclaration` and `MethodDeclaration` implement
        // different things to have this `returnType` getter so
        // unfortunately it can't be simplified.
        final returnType = node.returnType?.type;
        isWidgetReturned = returnType != null && hasWidgetType(returnType);
      } else {
        isWidgetReturned = false;
      }

      if (isWidgetReturned) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
