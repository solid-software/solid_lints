import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/no_empty_block/models/no_empty_block_parameters.dart';
import 'package:solid_lints/src/lints/no_empty_block/visitors/no_empty_block_visitor.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

// Inspired by TSLint (https://palantir.github.io/tslint/rules/no-empty/)

/// A `no_empty_block` rule which forbids having empty code blocks,
/// including function/method bodies and conditionals,
/// excluding catch blocks and to-do comments.
///
/// An empty code block often indicates missing code.
///
/// ### Example config:
///
/// ```yaml
/// solid_lints:
///   diagnostics:
///     no_empty_block:
///       allow_with_comments: true
///       exclude:
///         - method_name: build
///         - class_name: MyClass
///           method_name: build
/// ```
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// int fn() {} // LINT
///
/// Function getCallback() {
///   return (){}; // LINT
/// }
///
/// void main() {
///   if (true) {} // LINT
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// int fn() {
// ignore: todo
///  // TODO: complete this
/// }
///
/// Function getCallback() {
///   return () {
// ignore: todo
///     // TODO: actually do something
///   };
/// }
///
/// void main() {
///   if (true) {
///     print('');
///   }
///
///   try {
///     fn();
///   } catch (_) {} // ignored by this rule
/// }
/// ```
class NoEmptyBlockRule extends SolidLintRule<NoEmptyBlockParameters> {
  /// This lint rule represents
  /// the error whether left empty block.
  static const String lintName = 'no_empty_block';

  static const _code = LintCode(
    lintName,
    'Block is empty. Empty blocks are often indicators of missing code.',
  );

  @override
  DiagnosticCode get diagnosticCode => _code;

  /// Creates a new instance of [NoEmptyBlockRule]
  NoEmptyBlockRule({
    required super.analysisOptionsLoader,
  }) : super.withParameters(
         name: lintName,
         description: _code.problemMessage,
         parametersParser: NoEmptyBlockParameters.fromJson,
       );

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    super.registerNodeProcessors(registry, context);

    final parameters =
        getParametersForContext(context) ?? NoEmptyBlockParameters.empty();

    final visitor = NoEmptyBlockVisitor(
      rule: this,
      allowWithComments: parameters.allowWithComments,
      exclude: parameters.exclude,
    );

    registry.addCompilationUnit(this, visitor);
  }
}
