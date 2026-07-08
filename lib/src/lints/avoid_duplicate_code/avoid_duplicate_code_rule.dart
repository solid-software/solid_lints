import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/models/avoid_duplicate_code_parameters.dart';
import 'package:solid_lints/src/lints/avoid_duplicate_code/visitors/avoid_duplicate_code_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// A lint rule that detects duplicated code blocks (clones) within a single
/// file.
///
/// When two or more function/method/constructor bodies have structurally
/// identical AST subtrees (Type 2 clones — same structure, variable names
/// may differ), the rule reports all copies except the first occurrence.
///
/// ### Example config:
///
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       avoid_duplicate_code:
///         min_statements: 3
///         ignore_literals: false
///         ignore_identifiers: true
///         check_blocks: false
///         exclude:
///           - method_name: build
/// ```
class AvoidDuplicateCodeRule
    extends SolidLintRule<AvoidDuplicateCodeParameters> {
  /// Name of the lint.
  static const lintName = 'avoid_duplicate_code';

  static const _code = LintCode(
    lintName,
    'This code is a duplicate of the function/method at line {0}. '
    'Consider extracting the shared logic into a common function.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [AvoidDuplicateCodeRule].
  AvoidDuplicateCodeRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description:
             'Detects structurally identical function/method bodies '
             'within a single file (code clones).',
         parametersParser: AvoidDuplicateCodeParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ??
        AvoidDuplicateCodeParameters.empty();

    final visitor = AvoidDuplicateCodeVisitor(this, parameters);

    registry.addCompilationUnit(this, visitor);
  }
}
