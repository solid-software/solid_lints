import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/models/avoid_returning_widgets_parameters.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/visitors/avoid_returning_widgets_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A rule which warns about returning widgets from functions and methods.
///
/// Using functions instead of Widget subclasses for decomposing Widget trees
/// may cause unexpected behavior and performance issues.
///
/// Exceptions:
///   - overriden methods
///
/// More details: https://github.com/flutter/flutter/issues/19269
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       avoid_returning_widgets:
///         exclude:
///           - class_name: MyWidget
///             method_name: buildCustomButton
/// ```
///
/// ### Example
///
/// #### BAD:
///
/// ```dart
/// Widget avoidReturningWidgets() => const SizedBox(); // LINT
///
/// class MyWidget extends StatelessWidget {
///   Widget get box => SizedBox(); // LINT
///   Widget test1() => const SizedBox(); //LINT
///   Widget get _test3 => const SizedBox(); // LINT
/// }
/// ```
///
///
/// #### GOOD:
///
/// ```dart
/// class MyWidget extends MyWidget {
///
///   @override
///   Widget test1() => const SizedBox();
///
///   @override
///   Widget get box => ColoredBox(color: Colors.pink);
///
///   @override
///   Widget build(BuildContext context) {
///     return const SizedBox();
///   }
/// }
/// ```
class AvoidReturningWidgetsRule
    extends SolidLintRule<AvoidReturningWidgetsParameters> {
  /// This lint rule represents
  /// the error whether we return a widget.
  static const lintName = 'avoid_returning_widgets';

  static const _code = LintCode(
    lintName,
    'Returning a widget from a function is considered an anti-pattern. '
    'Unless you are overriding an existing method, '
    'consider extracting your widget to a separate class.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidReturningWidgetsRule]
  AvoidReturningWidgetsRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: _code.lowerCaseName,
         description: _code.problemMessage,
         parametersParser: AvoidReturningWidgetsParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        AvoidReturningWidgetsParameters.empty();

    final visitor = AvoidReturningWidgetsVisitor(this, parameters);

    registry.addCompilationUnit(this, visitor);
  }
}
