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
  var badD = -0.400e-5;

  void someMethod() {
    var badA = 5.230;
    double badB = -1.20;
    double badC = -1.200;
    double badExpr = 5.23 + 5.230;
    var badD = -0.400E-5;
  }
}
''',
      [
        lint(26, 5),
        lint(49, 4),
        lint(77, 5),
        lint(110, 5),
        lint(131, 8),

        lint(179, 5),
        lint(205, 4),
        lint(230, 5),
        lint(265, 5),
        lint(288, 8),
      ],
    );
  }

  Future<void> test_reports_on_leading_decimal_point() async {
    await assertDiagnostics(
      r'''
var badA = .23;
double badB = -.2;
double badExpr = 5.23 + .23;
var badD = .4e-5;

class Test {
  var badA = .23;
  double badB = -.2;
  double get badExpr => 5.23 + .23;
  double get badD => -.4E-5;
}
''',
      [
        lint(11, 3),
        lint(31, 2),
        lint(59, 3),
        lint(75, 5),

        lint(109, 3),
        lint(131, 2),
        lint(166, 3),
        lint(193, 5),
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
  var goodB = 0.16E+5;
  double goodC = -0.4E-5;
  double goodE = 5.23 + 0.4e-5;
  
  void someMethod() {
    const goodA = -0.25;
  }
}
''');
  }
}
