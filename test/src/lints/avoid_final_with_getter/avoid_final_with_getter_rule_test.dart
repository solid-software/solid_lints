import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_final_with_getter/avoid_final_with_getter_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidFinalWithGetterRuleTest);
  });
}

@reflectiveTest
class AvoidFinalWithGetterRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = AvoidFinalWithGetterRule();
    super.setUp();
  }

  Future<void> test_reports_on_getter_with_same_name_as_field() async {
    await assertAutoDiagnostics('''
class Test {
  final int _myField = 0;
  
  ${expectLint('int get myField => _myField;')}
}
''');
  }

  Future<void> test_reports_on_getter_with_different_name_from_field() async {
    await assertAutoDiagnostics('''
class Test {
  final int _myField = 0;
  
  ${expectLint('int get myFieldInt => _myField;')}
}
''');
  }

  Future<void> test_reports_on_static_getter_with_private_field() async {
    await assertAutoDiagnostics('''
class Test {
  static final int _myField = 0;
  
  ${expectLint('static int get myField => _myField;')}
}
''');
  }

  Future<void> test_reports_on_getter_with_this_property_access() async {
    await assertAutoDiagnostics('''
class Test {
  final int _myField = 0;
  
  ${expectLint('int get myField => this._myField;')}
}
''');
  }

  Future<void>
  test_reports_on_block_body_getter_returning_private_field() async {
    await assertAutoDiagnostics('''
class Test {
  final int _myField = 0;
  
  ${expectLint('''int get myField {
    return _myField;
  }''')}
}
''');
  }

  Future<void> test_does_not_report_on_getter_that_contains_logic() async {
    await assertNoDiagnostics(r'''
class Test {
  final int _myField = 0;
  final int _myField2 = 1;
  final int _myField3 = 2;
  
  int get myField => _myField + 1;

  int get myField2 => this._myField2 + 1;

  int get myField3 {
    return this._myField3 + 1;
  }
}
''');
  }

  Future<void> test_does_not_report_on_public_final_field() async {
    await assertNoDiagnostics(r'''
class Test {
  final int myField = 0;
}
''');
  }

  Future<void>
  test_does_not_report_on_getter_returning_mutable_private_field() async {
    await assertNoDiagnostics(r'''
class Test {
  int _myField = 0;
  int _myField2 = 1;
  int _myField3 = 2;
  
  int get myField => _myField;

  int get myField2 => this._myField2;

  int get myField3 {
    return _myField3;
  }
}
''');
  }
}
