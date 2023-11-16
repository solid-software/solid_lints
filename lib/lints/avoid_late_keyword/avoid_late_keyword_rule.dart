import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/avoid_late_keyword/models/avoid_late_keyword_parameters.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `late` keyword rule which forbids using it to avoid runtime exceptions.
class AvoidLateKeywordRule extends SolidLintRule<AvoidLateKeywordParameters> {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use `late` keyword.
  static const lintName = 'avoid_late_keyword';

  AvoidLateKeywordRule._(super.config);

  /// Creates a new instance of [AvoidLateKeywordRule]
  /// based on the lint configuration.
  factory AvoidLateKeywordRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      paramsParser: AvoidLateKeywordParameters.fromJson,
      problemMessage: (_) => 'Avoid using the "late" keyword. '
          'It may result in runtime exceptions.',
    );

    return AvoidLateKeywordRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      if (_shouldLint(node)) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _shouldLint(VariableDeclaration node) {
    final isLateDeclaration = node.declaredElement?.isLate ?? false;
    if (!isLateDeclaration) return false;

    final ignoredTypes = _hasIgnoredType(node);
    if (ignoredTypes) return false;

    final allowInitialized = config.parameters.allowInitialized;
    if (!allowInitialized) return true;

    final hasInitializer = node.initializer != null;
    return !hasInitializer;
  }

  bool _hasIgnoredType(VariableDeclaration node) =>
      config.parameters.ignoredTypes.contains(
        (node.parent! as VariableDeclarationList).type?.toSource() ?? '',
      );
}
