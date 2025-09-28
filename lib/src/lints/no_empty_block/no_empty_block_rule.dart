import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/no_empty_block/models/no_empty_block_parameters.dart';
import 'package:solid_lints/src/lints/no_empty_block/visitors/no_empty_block_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

// Inspired by TSLint (https://palantir.github.io/tslint/rules/no-empty/)

/// A `no_empty_block` rule which forbids having empty code blocks,
/// including function/method bodies and conditionals,
/// excluding catch blocks and to-do comments.
///
/// An empty code block often indicates missing code.
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
///  // TODO: complete this
/// }
///
/// Function getCallback() {
///   return () {
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

  NoEmptyBlockRule._(super.config);

  /// Creates a new instance of [NoEmptyBlockRule]
  /// based on the lint configuration.
  factory NoEmptyBlockRule.createRule(CustomLintConfigs configs) {
    final config = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: NoEmptyBlockParameters.fromJson,
      problemMessage: (_) =>
          'Block is empty. Empty blocks are often indicators '
          'of missing code.',
    );

    return NoEmptyBlockRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addDeclaration((node) {
      final isIgnored = config.parameters.exclude.shouldIgnore(node);
      if (isIgnored) return;

      final visitor = NoEmptyBlockVisitor(
        allowWithComments: config.parameters.allowWithComments,
      );
      node.accept(visitor);

      for (final emptyBlock in visitor.emptyBlocks) {
        reporter.atNode(emptyBlock, code);
      }
    });
  }
}
