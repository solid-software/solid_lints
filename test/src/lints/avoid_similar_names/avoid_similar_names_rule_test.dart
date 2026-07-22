import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/lints/avoid_similar_names/avoid_similar_names_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

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

  Future<void> test_reports_on_similar_names_in_function() => _assert('''
  int ${expectLint('someClass1')} = 1;
  int ${expectLint('someClass2')} = 2;
''');

  Future<void> test_does_not_report_on_different_types() => _assertNo('''
  String user1 = 'Alice';
  int user2 = 123;
''');

  Future<void> test_reports_on_similar_names_with_different_nullability() =>
      _assert('''
  int ${expectLint('user1')} = 1;
  int? ${expectLint('user2')} = 2;
''');

  Future<void> test_reports_on_borderline_short_names() => _assert('''
  int ${expectLint('id1')} = 1;
  int ${expectLint('id2')} = 2;
''');

  Future<void> test_does_not_report_on_different_descriptive_tokens() =>
      _assertNo('''
  int minHeight = 10;
  int maxHeight = 20;
''');

  Future<void> test_does_not_report_on_short_names() => _assertNo('''
  int x1 = 1;
  int x2 = 2;
  int dx = 5;
  int dy = 10;
''');

  Future<void> test_does_not_report_on_allowed_coordinates() => _assertNo('''
  double pointX = 1.0;
  double pointY = 2.0;
''');

  Future<void> test_reports_on_digits_in_parameters() =>
      assertAutoDiagnostics('''
bool isEqual(
  int ${expectLint('someClass1')},
  int ${expectLint('someClass2')},
) {
  return someClass1 == someClass2;
}
''');

  Future<void> test_reports_on_similar_names_in_method() =>
      assertAutoDiagnostics('''
class A {
  void test() {
    String ${expectLint('tempA')} = "a";
    String ${expectLint('tempB')} = "b";
  }
}
''');

  Future<void> test_reports_on_subset_with_extra_digit() => _assert('''
  String ${expectLint('data')} = "a";
  String ${expectLint('data1')} = "b";
''');

  Future<void> test_reports_on_subset_with_multi_digit_number() => _assert('''
  String ${expectLint('data')} = "a";
  String ${expectLint('data10')} = "b";
''');

  Future<void> test_reports_on_mixed_non_descriptive_suffixes() => _assert('''
  String ${expectLint('user1')} = "a";
  String ${expectLint('userA')} = "b";
''');

  Future<void> test_reports_on_subset_with_extra_letter() => _assert('''
  String ${expectLint('user')} = "a";
  String ${expectLint('userA')} = "b";
''');

  Future<void> test_does_not_report_on_subset_with_descriptive_token() =>
      _assertNo('''
  String user = "a";
  String userProfile = "b";
  String data = "c";
  String dataFetch = "d";
''');

  Future<void> test_reports_on_three_similar_names() => _assert('''
  int ${expectLint('id1')} = 1;
  int ${expectLint('id2')} = 2;
  int ${expectLint('id3')} = 3;
''');

  Future<void> test_does_not_report_on_anonymous_lambda() => _assertNo('''
  void process(int Function(int, int) callback) {}
  process((day1, day2) => day1 + day2);
''');

  Future<void> test_reports_on_acronym_and_camel_case_suffix() => _assert('''
  int ${expectLint('APIRequest')} = 1;
  int ${expectLint('apiRequest1')} = 2;
''');

  Future<void> test_reports_on_similar_names_in_for_in_loops() => _assert('''
  final users = [1, 2];
  for (final ${expectLint('user1')} in users) {
    int ${expectLint('user2')} = user1;
  }
''');

  Future<void>
  test_reports_on_similar_names_in_pattern_variable_declarations() =>
      _assert('''
  final (${expectLint('user1')}, ${expectLint('user2')}) = (1, 2);
''');

  Future<void> test_reports_on_similar_names_in_pattern_matching_if_case() =>
      assertAutoDiagnostics('''
void test(Object obj) {
  if (obj case [int ${expectLint('user1')}, int ${expectLint('user2')}]) {
    // ...
  }
}
''');

  Future<void> _assert(String body) =>
      assertAutoDiagnostics('''void test() {$body}''');

  Future<void> _assertNo(String body) =>
      assertNoDiagnostics('''void test() {$body}''');
}
