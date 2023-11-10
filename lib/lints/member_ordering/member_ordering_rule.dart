import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:solid_lints/lints/member_ordering/member_ordering_visitor.dart';
import 'package:solid_lints/lints/member_ordering/models/member_ordering_parameters.dart';
import 'package:solid_lints/models/rule_config.dart';
import 'package:solid_lints/models/solid_lint_rule.dart';

/// A `member_ordering` rule which
/// warns about class members being in wrong order
/// Custom order can be provided through config
class MemberOrderingRule extends SolidLintRule<MemberOrderingParameters> {
  /// The [LintCode] of this lint rule that represents
  /// the error whether we use bad formatted double literals.
  static const lintName = 'member_ordering';

  static const _warningMessage = 'should be before';
  static const _warningAlphabeticalMessage = 'should be alphabetically before';
  static const _warningTypeAlphabeticalMessage =
      'type name should be alphabetically before';

  MemberOrderingRule._(super.config);

  /// Creates a new instance of [MemberOrderingRule]
  /// based on the lint configuration.
  factory MemberOrderingRule.createRule(CustomLintConfigs configs) {
    final config = RuleConfig<MemberOrderingParameters>(
      configs: configs,
      name: lintName,
      paramsParser: MemberOrderingParameters.fromJson,
      problemMessage: (_) => "Order of class member is wrong",
    );

    return MemberOrderingRule._(config);
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final visitor = MemberOrderingVisitor(
        config.parameters.groupsOrder,
        config.parameters.widgetsGroupsOrder,
      );

      final membersInfo = visitor.visitClassDeclaration(node);
      final wrongOrderMembers = membersInfo.where(
        (info) => info.memberOrder.isWrong,
      );

      for (final memberInfo in wrongOrderMembers) {
        reporter.reportErrorForNode(
          _createWrongOrderLintCode(memberInfo),
          memberInfo.classMember,
        );
      }

      if (config.parameters.alphabetize) {
        final alphabeticallyWrongOrderMembers = membersInfo.where(
          (info) => info.memberOrder.isAlphabeticallyWrong,
        );

        for (final memberInfo in alphabeticallyWrongOrderMembers) {
          reporter.reportErrorForNode(
            _createAlphabeticallyWrongOrderLintCode(memberInfo),
            memberInfo.classMember,
          );
        }
      }

      if (!config.parameters.alphabetize &&
          config.parameters.alphabetizeByType) {
        final alphabeticallyByTypeWrongOrderMembers = membersInfo.where(
          (info) => info.memberOrder.isByTypeWrong,
        );

        for (final memberInfo in alphabeticallyByTypeWrongOrderMembers) {
          reporter.reportErrorForNode(
            _createAlphabeticallyByTypeWrongOrderLintCode(memberInfo),
            memberInfo.classMember,
          );
        }
      }
    });
  }

  LintCode _createWrongOrderLintCode(MemberInfo info) {
    final memberGroup = info.memberOrder.memberGroup;
    final previousMemberGroup = info.memberOrder.previousMemberGroup;

    return LintCode(
      name: lintName,
      problemMessage: "$memberGroup $_warningMessage $previousMemberGroup.",
    );
  }

  LintCode _createAlphabeticallyWrongOrderLintCode(MemberInfo info) {
    final names = info.memberOrder.memberNames;
    final current = names.currentName;
    final previous = names.previousName;

    return LintCode(
      name: lintName,
      problemMessage: "$current $_warningAlphabeticalMessage $previous.",
    );
  }

  LintCode _createAlphabeticallyByTypeWrongOrderLintCode(MemberInfo info) {
    final names = info.memberOrder.memberNames;
    final current = names.currentName;
    final previous = names.previousName;

    return LintCode(
      name: lintName,
      problemMessage: "$current $_warningTypeAlphabeticalMessage $previous",
    );
  }
}
