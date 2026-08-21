import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';

/// A fake implementation of [RuleVisitorRegistry] for model tests.
class FakeRuleVisitorRegistry implements RuleVisitorRegistry {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
