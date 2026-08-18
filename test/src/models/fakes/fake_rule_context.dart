import 'package:analyzer/analysis_rule/rule_context.dart';

/// A fake implementation of [RuleContext] for model tests.
class FakeRuleContext implements RuleContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
