import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:solid_lints/src/models/filtering_diagnostic_reporter.dart';
import 'package:solid_lints/src/models/proxy_analysis_rule.dart';
import 'package:test/test.dart';

import '../utils/fake_analysis_options_loader.dart';
import 'fakes/fake_rule_context.dart';
import 'fakes/fake_rule_visitor_registry.dart';
import 'fakes/fake_source.dart';

void main() {
  group('ProxyAnalysisRule', () {
    late _MockAnalysisRule delegate;
    late FakeAnalysisOptionsLoader loader;
    late FakeRuleVisitorRegistry registry;
    late FakeRuleContext context;
    late ProxyAnalysisRule proxyRule;

    setUp(() {
      delegate = _MockAnalysisRule();
      loader = FakeAnalysisOptionsLoader();
      registry = FakeRuleVisitorRegistry();
      context = FakeRuleContext();
      proxyRule = ProxyAnalysisRule(delegate, loader);
    });

    test('delegates to wrapped rule when enabled and not excluded', () {
      loader.isRuleDisabledResult = false;
      loader.isFileExcludedResult = false;

      proxyRule.registerNodeProcessors(registry, context);

      expect(delegate.registerNodeProcessorsCalled, isTrue);
      expect(delegate.lastRegistry, same(registry));
      expect(delegate.lastContext, same(context));
    });

    test('does not delegate when rule is disabled', () {
      loader.isRuleDisabledResult = true;
      loader.isFileExcludedResult = false;

      proxyRule.registerNodeProcessors(registry, context);

      expect(delegate.registerNodeProcessorsCalled, isFalse);
    });

    test('does not delegate when file is excluded', () {
      loader.isRuleDisabledResult = false;
      loader.isFileExcludedResult = true;

      proxyRule.registerNodeProcessors(registry, context);

      expect(delegate.registerNodeProcessorsCalled, isFalse);
    });

    test('wraps reporter in FilteringDiagnosticReporter', () {
      final originalReporter = DiagnosticReporter(
        DiagnosticListener.nullListener,
        FakeSource('/path/to/file.dart'),
      );

      proxyRule.reporter = originalReporter;

      expect(delegate.reporter, isA<FilteringDiagnosticReporter>());
    });

    test('delegates getters and properties', () {
      expect(proxyRule.diagnosticCode, equals(delegate.diagnosticCode));
      expect(proxyRule.name, equals(delegate.name));
      expect(proxyRule.description, equals(delegate.description));
      expect(proxyRule.canUseParsedResult, equals(delegate.canUseParsedResult));
      expect(proxyRule.incompatibleRules, equals(delegate.incompatibleRules));
      expect(proxyRule.pubspecVisitor, equals(delegate.pubspecVisitor));
    });
  });
}

class _MockAnalysisRule extends AnalysisRule {
  bool registerNodeProcessorsCalled = false;
  RuleVisitorRegistry? lastRegistry;
  RuleContext? lastContext;
  DiagnosticReporter? lastReporter;

  _MockAnalysisRule()
    : super(name: 'mock_rule', description: 'Mock rule description');

  @override
  DiagnosticCode get diagnosticCode => const LintCode('mock_rule', 'Mock code');

  DiagnosticReporter get reporter => lastReporter!;

  @override
  set reporter(DiagnosticReporter value) {
    super.reporter = value;
    lastReporter = value;
  }

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registerNodeProcessorsCalled = true;
    lastRegistry = registry;
    lastContext = context;
  }
}
