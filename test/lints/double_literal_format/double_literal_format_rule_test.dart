import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DoubleLiteralFormatRuleTest);
  });
}

@reflectiveTest
class DoubleLiteralFormatRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = DoubleLiteralFormatRule();
    super.setUp();
  }

  Future<void> test_reports_on_leading_zeros() async {
    await assertDiagnostics(
      r'''
var badA = 05.23;
double badB = -01.2;
double badC = -001.2;
double badExpr = 5.23 + 05.23;

class Test {
  var badA = 05.23;
  double badB = -01.2;
  double badC = -001.2;
  double badExpr = 5.23 + 05.23;
}
''',
      [
        lint(11, 5),
        lint(33, 4),
        lint(54, 5),
        lint(85, 5),

        lint(119, 5),
        lint(143, 4),
        lint(166, 5),
        lint(199, 5),
      ],
    );
  }

  Future<void> test_reports_on_trailing_zeros() async {
    await assertDiagnostics(
      r'''
class Test {
  var badA = 5.230;
  final badB = -1.20;
  double get badC => -1.200;
  double badExpr = 5.23 + 5.230;
  
  void someMethod() {
    var badA = 5.230;
    double badB = -1.20;
    double badC = -1.200;
    double badExpr = 5.23 + 5.230;
  }
}
''',
      [
        lint(26, 5),
        lint(49, 4),
        lint(77, 5),
        lint(110, 5),

        lint(157, 5),
        lint(183, 4),
        lint(208, 5),
        lint(243, 5),
      ],
    );
  }

  Future<void> test_reports_on_leading_decimal_point() async {
    await assertDiagnostics(
      r'''
var badA = .23;
double badB = -.2;
double badExpr = 5.23 + .23;

class Test {
  var badA = .23;
  double badB = -.2;
  double get badExpr => 5.23 + .23;
}
''',
      [
        lint(11, 3),
        lint(31, 2),
        lint(59, 3),

        lint(91, 3),
        lint(113, 2),
        lint(148, 3),
      ],
    );
  }

  void test_does_not_report_on_non_double_literals() async {
    await assertNoDiagnostics(r'''
var badA = '05.23';
var stringA = '5.23';
final badB = '.04';
var intA = 0;
''');
  }

  Future<void> test_does_not_report_on_good_literals() async {
    await assertNoDiagnostics(r'''
var goodA = 5.23;
double goodB = -1.2;

double goodExpr = 5.23 + 5.23;
class DoubleLiteralFormatTest {
  var goodA = 0.16e+5;
  
  void someMethod() {
    const goodA = -0.25;
  }
}
''');
  }
}
