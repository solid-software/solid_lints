import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_first/prefer_first_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferFirstRuleTest);
  });
}

@reflectiveTest
class PreferFirstRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferFirstRule();
    super.setUp();
  }

  void test_reports_on_list_index_access_with_zero_literal() async {
    await assertDiagnostics(
      r'''
final list1 = [0, 1, 2, 3];
var a = list1[0];

void main () {
  final list2 = [1, 0, 2, 3];
  list1[0];
  list2[0];
}
''',
      [lint(36, 8), lint(94, 8), lint(106, 8)],
    );
  }

  void
  test_does_not_report_on_list_index_access_with_variable_or_constant() async {
    await assertNoDiagnostics(r'''
const zero = 0;
final zeroVar = 0;

final list = [0, 1, 2, 3];

var a = list[zero];
var b = list[1 - 1];
var c = list[zeroVar];
''');
  }

  void test_reports_on_list_subclasses() async {
    await assertDiagnostics(
      r'''
abstract class MyList<T> implements List<T> {}

T getFirst<T>(MyList<T> list) {
  return list[0];
}
''',
      [lint(89, 7)],
    );
  }

  void test_reports_on_element_at_access_with_zero_literal() async {
    await assertDiagnostics(
      r'''
final list1 = [0, 1, 2, 3];
var a = list1.elementAt(0);

void main () {
  final list2 = [1, 0, 2, 3];
  list1.elementAt(0);
  list2.elementAt(0);
}
''',
      [lint(36, 18), lint(104, 18), lint(126, 18)],
    );
  }

  void
  test_does_not_report_on_element_at_access_with_variable_or_constant() async {
    await assertNoDiagnostics(r'''
const zero = 0;
final zeroVar = 0;

final list = [0, 1, 2, 3];

var a = list.elementAt(zero);
var b = list.elementAt(1 - 1);
var c = list.elementAt(zeroVar);
''');
  }

  void test_reports_on_iterable_subclasses() async {
    await assertDiagnostics(
      r'''
abstract class MyIterable<T> implements Iterable<T> {}

T getFirst<T>(MyIterable<T> iterable) {
  return iterable.elementAt(0);
}

void main () {
  final set = {0, 1, 2, 3};
  final map = {0: 0, 1: 1, 2: 2, 3: 3};

  set.elementAt(0);
  map.keys.elementAt(0);
  map.values.elementAt(0);
}
''',
      [lint(105, 21), lint(217, 16), lint(237, 21), lint(262, 23)],
    );
  }
}
