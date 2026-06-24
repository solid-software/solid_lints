import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/models/function_lines_of_code_parameters.dart';
import 'package:solid_lints/src/lints/function_lines_of_code/visitors/function_lines_of_code_rule_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// An approximate metric of meaningful lines of source code inside a function,
/// excluding blank lines and comments.
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       function_lines_of_code:
///         max_lines: 100
///         exclude:
///           - "Build"
/// ```
class FunctionLinesOfCodeRule
    extends SolidLintRule<FunctionLinesOfCodeParameters> {
  /// This lint rule name.
  static const lintName = 'function_lines_of_code';

  static const _code = LintCode(
    lintName,
    'The maximum allowed number of lines is {0}. '
    'Try splitting this function into smaller parts.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [FunctionLinesOfCodeRule]
  FunctionLinesOfCodeRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'An approximate metric of meaningful lines of source code '
             'inside a function, excluding blank lines and comments.',
         parametersParser: FunctionLinesOfCodeParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        FunctionLinesOfCodeParameters.empty();

    final visitor = FunctionLinesOfCodeRuleVisitor(this, context, parameters);

    registry.addCompilationUnit(this, visitor);
  }
}
