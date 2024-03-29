import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/lints/feature_envy/visitors/feature_envy_visitor.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

/// Warns if class methods are using fields from a different class(feature envy)
///
///
/// ### Example
/// BAD:
/// ```
/// class A {
///   int field;
///   A(this.field);
/// }
///
/// class B {
///   int method(A a) => a.field * a.field;//LINT
/// }
/// ```
///
/// GOOD:
/// ```
/// class A {
///   int field;
///   A(this.field);
///
///   int method() => field * field;
/// }
///
/// class B {
///   int method(A a) => a.method();
/// }
class FeatureEnvyRule extends SolidLintRule {
  /// The [LintCode] of this lint rule that represents the error if
  /// 'if' statements or conditional expression is redundant
  static const String lintName = 'feature_envy';
  static const String _problemMessage = '''
Don't access fields from class `A` in class `B`.
Consider encapsulating logic related to class `B` in class `B`.''';

  FeatureEnvyRule._(super.config);

  /// Creates a new instance of [FeatureEnvyRule]
  /// based on the lint configuration.
  factory FeatureEnvyRule.createRule(CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (value) => _problemMessage,
    );

    return FeatureEnvyRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      final visitor = FeatureEnvyVisitor();
      node.accept(visitor);

      for (final element in visitor.nodes) {
        reporter.reportErrorForNode(code, element);
      }
    });
  }
}
