import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/avoid_final_with_getter_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidFinalWithGetterRuleTest);
  });
}

@reflectiveTest
class AvoidFinalWithGetterRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidFinalWithGetterRule();
    super.setUp();
  }

  Future<void> test_reports_on_getter_with_same_name_as_field() async {
    await assertDiagnostics(
      r'''
class Test {
  final int _myField = 0;
  
  int get myField => _myField;
}
''',
      [lint(44, 28)],
    );
  }

  Future<void> test_reports_on_getter_with_different_name_from_field() async {
    await assertDiagnostics(
      r'''
class Test {
  final int _myField = 0;
  
  int get myFieldInt => _myField;
}
''',
      [lint(44, 31)],
    );
  }

  Future<void> test_reports_on_static_getter_with_private_field() async {
    await assertDiagnostics(
      r'''
class Test {
  static final int _myField = 0;
  
  static int get myField => _myField;
}
''',
      [lint(51, 35)],
    );
  }

  Future<void> test_does_not_report_on_getter_that_contains_logic() async {
    await assertNoDiagnostics(
      r'''
class Test {
  final int _myField = 0;
  
  int get myField => _myField + 1;
}
''',
    );
  }

  Future<void> test_does_not_report_on_public_final_field() async {
    await assertNoDiagnostics(
      r'''
class Test {
  final int myField = 0;
}
''',
    );
  }

  Future<void>
      test_does_not_report_on_getter_returning_mutable_private_field() async {
    await assertNoDiagnostics(
      r'''
class Test {
  int _myField = 0;

  int get myField => _myField;
}
''',
    );
  }
}
