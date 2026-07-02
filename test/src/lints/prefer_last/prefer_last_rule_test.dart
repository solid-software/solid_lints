import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_last/prefer_last_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferLastRuleTest);
  });
}

@reflectiveTest
class PreferLastRuleTest extends AnalysisRuleTest with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = PreferLastRule();
    super.setUp();
  }

  void test_reports_on_list_index_access_with_length_minus_one() async {
    await assertAutoDiagnostics('''
final list1 = [0, 1, 2, 3];
var a = ${expectLint('list1[list1.length - 1]')};

void main () {
  final list2 = [1, 0, 2, 3];
  ${expectLint('list1[list1.length - 1]')};
  ${expectLint('list2[list2.length - 1]')};
}
''');
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
    await assertAutoDiagnostics('''
abstract class MyList<T> implements List<T> {}

T getLast<T>(MyList<T> list) {
  return ${expectLint('list[list.length - 1]')};
}
''');
  }

  void test_reports_on_element_at_access_with_length_minus_one() async {
    await assertAutoDiagnostics('''
final list1 = [0, 1, 2, 3];
var a = ${expectLint('list1.elementAt(list1.length - 1)')};

void main () {
  final list2 = [1, 0, 2, 3];
  ${expectLint('list1.elementAt(list1.length - 1)')};
  ${expectLint('list2.elementAt(list2.length - 1)')};
}
''');
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
    await assertAutoDiagnostics('''
abstract class MyIterable<T> implements Iterable<T> {}

T getLast<T>(MyIterable<T> iterable) {
  return ${expectLint('iterable.elementAt(iterable.length - 1)')};
}

void main () {
  final set = {0, 1, 2, 3};
  final map = {0: 0, 1: 1, 2: 2, 3: 3};

  ${expectLint('set.elementAt(set.length - 1)')};
  ${expectLint('map.keys.elementAt(map.keys.length - 1)')};
  ${expectLint('map.values.elementAt(map.values.length - 1)')};
}
''');
  }

  void test_reports_on_cascade_element_at_access_with_length_minus_one() async {
    await assertAutoDiagnostics('''
void main () {
  final list2 = [1, 0, 2, 3];
  list2${expectLint('..elementAt(list2.length - 1)')};
}
''');
  }

  void test_reports_on_null_aware_index_access_with_length_minus_one() async {
    await assertAutoDiagnostics('''
List<int>? list1 = [0, 1, 2, 3];
var a = ${expectLint('list1?[list1!.length - 1]')};

void test(List<int>? list2) {
  ${expectLint('list1?[list1!.length - 1]')};
  ${expectLint('list2?[list2.length - 1]')};
}
''');
  }

  void
  test_reports_on_null_aware_element_at_access_with_length_minus_one() async {
    await assertAutoDiagnostics('''
List<int>? list1 = [0, 1, 2, 3];
var a = ${expectLint('list1?.elementAt(list1!.length - 1)')};

void test(List<int>? list2) {
  ${expectLint('list1?.elementAt(list1!.length - 1)')};
  ${expectLint('list2?.elementAt(list2.length - 1)')};
}
''');
  }
}
