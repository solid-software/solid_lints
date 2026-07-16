import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/avoid_similar_names_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidSimilarNamesRuleTest);
  });
}

@reflectiveTest
class AvoidSimilarNamesRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidSimilarNamesRule();
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name]),
    );
  }

  Future<void> test_reports_on_similar_names_in_function() async {
    await assertAutoDiagnostics('''
void test() {
  int ${expectLint('someClass1')} = 1;
  int ${expectLint('someClass2')} = 2;
}
''');
  }

  Future<void> test_does_not_report_on_different_types() async {
    await assertNoDiagnostics('''
void test() {
  String user1 = 'Alice';
  int user2 = 123;
}
''');
  }

  Future<void> test_reports_on_borderline_short_names() async {
    await assertAutoDiagnostics('''
void test() {
  int ${expectLint('id1')} = 1;
  int ${expectLint('id2')} = 2;
}
''');
  }

  Future<void> test_does_not_report_on_different_descriptive_tokens() async {
    await assertNoDiagnostics('''
void test() {
  int minHeight = 10;
  int maxHeight = 20;
}
''');
  }

  Future<void> test_does_not_report_on_short_names() async {
    await assertNoDiagnostics('''
void test() {
  int x1 = 1;
  int x2 = 2;
  int dx = 5;
  int dy = 10;
}
''');
  }

  Future<void> test_does_not_report_on_allowed_coordinates() async {
    await assertNoDiagnostics('''
void test() {
  double pointX = 1.0;
  double pointY = 2.0;
}
''');
  }

  Future<void> test_reports_on_digits_in_parameters() async {
    await assertAutoDiagnostics('''
bool isEqual(
  int ${expectLint('someClass1')},
  int ${expectLint('someClass2')},
) {
  return someClass1 == someClass2;
}
''');
  }

  Future<void> test_reports_on_similar_names_in_method() async {
    await assertAutoDiagnostics('''
class A {
  void test() {
    String ${expectLint('tempA')} = "a";
    String ${expectLint('tempB')} = "b";
  }
}
''');
  }

  Future<void> test_reports_on_subset_with_extra_digit() async {
    await assertAutoDiagnostics('''
void test() {
  String ${expectLint('data')} = "a";
  String ${expectLint('data1')} = "b";
}
''');
  }

  Future<void> test_reports_on_mixed_non_descriptive_suffixes() async {
    await assertAutoDiagnostics('''
void test() {
  String ${expectLint('user1')} = "a";
  String ${expectLint('userA')} = "b";
}
''');
  }

  Future<void> test_reports_on_subset_with_extra_letter() async {
    await assertAutoDiagnostics('''
void test() {
  String ${expectLint('user')} = "a";
  String ${expectLint('userA')} = "b";
}
''');
  }

  Future<void> test_does_not_report_on_subset_with_descriptive_token() async {
    await assertNoDiagnostics('''
void test() {
  String user = "a";
  String userProfile = "b";
  String data = "c";
  String dataFetch = "d";
}
''');
  }

  Future<void> test_reports_on_three_similar_names() async {
    await assertAutoDiagnostics('''
void test() {
  int ${expectLint('id1')} = 1;
  int ${expectLint('id2')} = 2;
  int ${expectLint('id3')} = 3;
}
''');
  }

  Future<void> test_does_not_report_on_anonymous_lambda() async {
    await assertNoDiagnostics('''
void test() {
  void process(int Function(int, int) callback) {}
  process((day1, day2) => day1 + day2);
}
''');
  }

  Future<void> test_reports_on_acronym_and_camel_case_suffix() async {
    await assertAutoDiagnostics('''
void test() {
  int ${expectLint('APIRequest')} = 1;
  int ${expectLint('apiRequest1')} = 2;
}
''');
  }
}
