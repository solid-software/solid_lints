import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/prefer_first/prefer_first_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferFirstRuleTest);
  });
}

@reflectiveTest
class PreferFirstRuleTest extends AnalysisRuleTest with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = PreferFirstRule();
    super.setUp();
  }

  void test_reports_on_list_index_access_with_zero_literal() async {
    await assertAutoDiagnostics('''
final list1 = [0, 1, 2, 3];
var a = ${expectLint('list1[0]')};

void main () {
  final list2 = [1, 0, 2, 3];
  ${expectLint('list1[0]')};
  ${expectLint('list2[0]')};
}
''');
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
    await assertAutoDiagnostics('''
abstract class MyList<T> implements List<T> {}

T getFirst<T>(MyList<T> list) {
  return ${expectLint('list[0]')};
}
''');
  }

  void test_reports_on_element_at_access_with_zero_literal() async {
    await assertAutoDiagnostics('''
final list1 = [0, 1, 2, 3];
var a = ${expectLint('list1.elementAt(0)')};

void main () {
  final list2 = [1, 0, 2, 3];
  ${expectLint('list1.elementAt(0)')};
  ${expectLint('list2.elementAt(0)')};
}
''');
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
    await assertAutoDiagnostics('''
abstract class MyIterable<T> implements Iterable<T> {}

T getFirst<T>(MyIterable<T> iterable) {
  return ${expectLint('iterable.elementAt(0)')};
}

void main () {
  final set = {0, 1, 2, 3};
  final map = {0: 0, 1: 1, 2: 2, 3: 3};

  ${expectLint('set.elementAt(0)')};
  ${expectLint('map.keys.elementAt(0)')};
  ${expectLint('map.values.elementAt(0)')};
}
''');
  }
}
