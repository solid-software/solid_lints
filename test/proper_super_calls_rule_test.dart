import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/proper_super_calls/proper_super_calls_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProperSuperCallsRuleTest);
  });
}

@reflectiveTest
class ProperSuperCallsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = ProperSuperCallsRule();
    super.setUp();
  }

  @override
  String get analysisRule => ProperSuperCallsRule.lintName;

  /// Mocks the Flutter framework parts relevant to this lint.
  String get _flutterBase => r'''
abstract class StatefulWidget {}
abstract class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
}
''';

  void test_initState_reports_when_not_first() async {
    await assertDiagnostics(
        _flutterBase +
            r'''
class MyWidgetState extends State<StatefulWidget> {
  @override
  void initState() {
    print('Bad');
    super.initState();
  }
}
''',
        [
          lint(197, 9), // Highlights 'initState'
        ]);
  }

  void test_dispose_reports_when_not_last() async {
    await assertDiagnostics(
        _flutterBase +
            r'''
class MyWidgetState extends State<StatefulWidget> {
  @override
  void dispose() {
    super.dispose();
    print('Bad');
  }
}
''',
        [
          lint(197, 7), // Highlights 'dispose'
        ]);
  }

  void test_no_report_for_correct_flutter_usage() async {
    await assertNoDiagnostics(_flutterBase +
        r'''
class MyWidgetState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
    print('Good');
  }

  @override
  void dispose() {
    print('Good');
    super.dispose();
  }
}
''');
  }
}
