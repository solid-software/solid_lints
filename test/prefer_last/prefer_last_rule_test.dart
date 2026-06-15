import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_last/prefer_last_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferLastRuleTest);
  });
}

@reflectiveTest
class PreferLastRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferLastRule();
    super.setUp();
  }

  void test_reports_on_list_index_access_with_length_minus_one() async {
    await assertDiagnostics(
      r'''
final list1 = [0, 1, 2, 3];
var a = list1[list1.length - 1];

void main () {
  final list2 = [1, 0, 2, 3];
  list1[list1.length - 1];
  list2[list2.length - 1];
}
''',
      [lint(36, 23), lint(109, 23), lint(136, 23)],
    );
  }

  void
  test_does_not_report_on_list_index_access_with_variable_or_constant() async {
    await assertNoDiagnostics(r'''
final list = [0, 1, 2, 3];
final length = list.length - 1;

var a = list[length - 1];
''');
  }

  void test_reports_on_list_subclasses() async {
    await assertDiagnostics(
      r'''
abstract class MyList<T> implements List<T> {}

T getLast<T>(MyList<T> list) {
  return list[list.length - 1];
}
''',
      [lint(88, 21)],
    );
  }

  void test_reports_on_element_at_access_with_length_minus_one() async {
    await assertDiagnostics(
      r'''
final list1 = [0, 1, 2, 3];
var a = list1.elementAt(list1.length - 1);

void main () {
  final list2 = [1, 0, 2, 3];
  list1.elementAt(list1.length - 1);
  list2.elementAt(list2.length - 1);
}
''',
      [lint(36, 33), lint(119, 33), lint(156, 33)],
    );
  }

  void
  test_does_not_report_on_element_at_access_with_variable_or_constant() async {
    await assertNoDiagnostics(r'''
final list = [0, 1, 2, 3];
final length = list.length - 1;

var a = list.elementAt(length - 1);
''');
  }

  void test_reports_on_iterable_subclasses() async {
    await assertDiagnostics(
      r'''
abstract class MyIterable<T> implements Iterable<T> {}

T getLast<T>(MyIterable<T> iterable) {
  return iterable.elementAt(iterable.length - 1);
}

void main () {
  final set = {0, 1, 2, 3};
  final map = {0: 0, 1: 1, 2: 2, 3: 3};

  set.elementAt(set.length - 1);
  map.keys.elementAt(map.keys.length - 1);
  map.values.elementAt(map.values.length - 1);
}
''',
      [lint(104, 39), lint(234, 29), lint(267, 39), lint(310, 43)],
    );
  }
}
