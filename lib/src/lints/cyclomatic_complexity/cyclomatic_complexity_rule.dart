import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/models/cyclomatic_complexity_parameters.dart';
import 'package:solid_lints/src/lints/cyclomatic_complexity/visitors/cyclomatic_complexity_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Limit for the number of linearly independent paths through a program's
/// source code.
///
/// Counts the number of code branches and loop statements within function and
/// method bodies.
///
/// ### Example config:
///
/// This configuration will allow 10 code branchings per function body before
/// triggering a warning.
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       cyclomatic_complexity:
///         max_complexity: 10
/// ```
class CyclomaticComplexityRule
    extends SolidLintRule<CyclomaticComplexityParameters> {
  /// Name of the lint.
  static const lintName = 'cyclomatic_complexity';

  static const _code = LintCode(
    lintName,
    'The maximum allowed complexity of a function is {0}. Please decrease it.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [CyclomaticComplexityRule].
  CyclomaticComplexityRule({
    required super.analysisOptionsLoader,
    required super.parametersParser,
  }) : super.withParameters(
          name: _code.lowerCaseName,
          description:
              'Limit for the number of linearly independent paths '
              "through a program's source code.",
        );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters = getParametersForContext(context) ??
        CyclomaticComplexityParameters.empty();

    final visitor = CyclomaticComplexityVisitor(this, parameters);

    registry.addCompilationUnit(this, visitor);
  }
}
