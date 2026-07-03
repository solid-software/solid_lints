import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/proper_super_calls/proper_super_calls_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ProperSuperCallsRuleTest);
  });
}

@reflectiveTest
class ProperSuperCallsRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    final flutter = newPackage('flutter');
    flutter.addFile('lib/src/widgets/framework.dart', r'''
abstract class StatefulWidget {}

abstract class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
}
''');

    rule = ProperSuperCallsRule();
    super.setUp();
  }

  Future<void> test_initState_reports_when_super_not_first() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  @override
  void ${expectLint('initState')}() {
    print('Bad');
    super.initState();
  }
}
''');
  }

  Future<void> test_dispose_reports_when_super_not_last() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  @override
  void ${expectLint('dispose')}() {
    super.dispose();
    print('Bad');
  }
}
''');
  }

  Future<void> test_reports_even_without_explicit_override_annotation() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  void ${expectLint('initState')}() {
    print('Bad');
    super.initState();
  }
}
''');
  }

  Future<void> test_reports_empty_body_missing_super() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  @override
  void ${expectLint('initState')}() {}
}
''');
  }

  Future<void> test_reports_when_wrong_super_method_is_called() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  @override
  void ${expectLint('initState')}() {
    super.dispose();  
    print('Bad');
  }
}
''');
  }

  Future<void> test_reports_in_deep_inheritance() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

abstract class BaseState extends State<StatefulWidget> {}

class MyWidgetState extends BaseState {
  @override
  void ${expectLint('dispose')}() {
    super.dispose();
    print('Bad');
  }
}
''');
  }

  Future<void> test_no_report_for_correct_usage() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
    print('Good');
  }

  @override
  void dispose() {
    print('Good');
    super.dispose();
  }
}
''');
  }

  Future<void> test_no_report_for_other_methods() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  void build() {
    super.initState();   
  }
}
''');
  }

  Future<void> test_no_report_for_async_correct_usage() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  @override
  Future<void> initState() async {
    // ignore: use_of_void_result
    await super.initState();
    print('');
  }

  @override
  Future<void> dispose() async {
    print('');
    // ignore: use_of_void_result
    await super.dispose();
  }
}
''');
  }

  Future<void>
  test_no_report_for_parenthesized_and_async_correct_usage() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class MyWidgetState extends State<StatefulWidget> {
  @override
  Future<void> initState() async {
    // ignore: use_of_void_result
    await (super.initState());
    print('');
  }

  @override
  Future<void> dispose() async {
    print('');
    // ignore: use_of_void_result
    (await super.dispose());
  }
}
''');
  }
}
