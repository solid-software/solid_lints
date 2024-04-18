import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/src/models/rule_config.dart';
import 'package:solid_lints/src/models/solid_lint_rule.dart';

class ConsiderMakingAMemberPrivateRule extends SolidLintRule {
  static const lintName = 'consider_making_a_member_private';

  ConsiderMakingAMemberPrivateRule._(super.config);

  factory ConsiderMakingAMemberPrivateRule.createRule(
      CustomLintConfigs configs) {
    final rule = RuleConfig(
      configs: configs,
      name: lintName,
      problemMessage: (_) => "Consider making a member private",
    );

    return ConsiderMakingAMemberPrivateRule._(rule);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // TODO: Implement the rule
  }
}
