import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/double_literal_format/double_literal_format_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DoubleLiteralFormatRuleTest);
  });
}

@reflectiveTest
class DoubleLiteralFormatRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = DoubleLiteralFormatRule();
    super.setUp();
  }

  Future<void> test_reports_on_leading_zeros() async {
    await assertAutoDiagnostics('''
var badA = ${expectLint('05.23')};
double badB = -${expectLint('01.2')};
double badC = -${expectLint('001.2')};
double badExpr = 5.23 + ${expectLint('05.23')};

class Test {
  var badA = ${expectLint('05.23')};
  double badB = -${expectLint('01.2')};
  double badC = -${expectLint('001.2')};
  double badExpr = 5.23 + ${expectLint('05.23')};
}
''');
  }

  Future<void> test_reports_on_trailing_zeros() async {
    await assertAutoDiagnostics('''
class Test {
  var badA = ${expectLint('5.230')};
  final badB = -${expectLint('1.20')};
  double get badC => -${expectLint('1.200')};
  double badExpr = 5.23 + ${expectLint('5.230')};
  var badD = -${expectLint('0.400e-5')};

  void someMethod() {
    var badA = ${expectLint('5.230')};
    double badB = -${expectLint('1.20')};
    double badC = -${expectLint('1.200')};
    double badExpr = 5.23 + ${expectLint('5.230')};
    var badD = -${expectLint('0.400E-5')};
  }
}
''');
  }

  Future<void> test_reports_on_leading_decimal_point() async {
    await assertAutoDiagnostics('''
var badA = ${expectLint('.23')};
double badB = -${expectLint('.2')};
double badExpr = 5.23 + ${expectLint('.23')};
var badD = ${expectLint('.4e-5')};

class Test {
  var badA = ${expectLint('.23')};
  double badB = -${expectLint('.2')};
  double get badExpr => 5.23 + ${expectLint('.23')};
  double get badD => -${expectLint('.4E-5')};
}
''');
  }

  Future<void> test_does_not_report_on_non_double_literals() async {
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
