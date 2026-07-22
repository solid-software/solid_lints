// MIT License
//
// Copyright (c) 2020-2021 Dart Code Checker team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unnecessary_setstate/avoid_unnecessary_set_state_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessarySetStateRuleTest);
  });
}

@reflectiveTest
class AvoidUnnecessarySetStateRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    final flutter = newPackage('flutter');

    flutter.addFile('lib/src/widgets/framework.dart', r'''
abstract class Widget {}

abstract class StatefulWidget extends Widget {}

class BuildContext {}

abstract class State<T extends StatefulWidget> {
  void initState() {}
  void didUpdateWidget(T oldWidget) {}
  void setState(void Function() fn) {}

  Widget build(BuildContext context);
}

class Text extends Widget {
  final Object? data;
  Text(this.data);
}

class ElevatedButton extends Widget {
  final Function()? onPressed;
  final Function()? onLongPress;
  final Widget? child;

  ElevatedButton({this.onPressed, this.onLongPress, this.child});
}
''');

    rule = AvoidUnnecessarySetStateRule();
    super.setUp();
  }

  Future<void> test_reports_set_state_in_init_state() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';

  @override
  void initState() {
    super.initState();

    ${expectLint('setState(() {\n      _myString = "Hello";\n    })')};
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_reports_set_state_in_init_state_with_condition() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';
  final bool _condition = true;

  @override
  void initState() {
    super.initState();

    if (_condition) {
      ${expectLint('setState(() {\n        _myString = "Hello";\n      })')};
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_reports_set_state_in_init_state_through_method() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';
  final bool _condition = true;

  @override
  void initState() {
    super.initState();

    ${expectLint('myStateUpdateMethod()')};
  }

  void myStateUpdateMethod() {
    setState(() {
      _myString = "Hello";
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_reports_set_state_in_did_update_widget() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';

  @override
  void didUpdateWidget(StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    ${expectLint('setState(() {\n      _myString = "Hello";\n    })')};
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_reports_set_state_in_build_method() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';

  @override
  Widget build(BuildContext context) {
    ${expectLint('setState(() {\n      _myString = "Hello";\n    })')};
    
    return ElevatedButton(
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_reports_set_state_in_build_method_with_condition() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';
  final bool _condition = true;

  @override
  Widget build(BuildContext context) {
    if (_condition) {
      ${expectLint('setState(() {\n        _myString = "Hello";\n      })')};
    }
    
    return ElevatedButton(
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_reports_set_state_in_build_method_through_method() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';

  void myStateUpdateMethod() {
    setState(() {
      _myString = "Hello";
    });
  }

  @override
  Widget build(BuildContext context) {
    ${expectLint('myStateUpdateMethod()')};
    
    return ElevatedButton(
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_does_not_report_set_state_in_button_on_pressed() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';

  void myStateUpdateMethod() {
    setState(() {
      _myString = "Hello";
    });
  }

  @override
  Widget build(BuildContext context) {    
    return ElevatedButton(
      onPressed: myStateUpdateMethod,
      child: Text(_myString),
    );
  }
}
''');
  }

  Future<void> test_does_not_report_set_state_in_button_on_long_press() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class _MyWidgetState extends State<StatefulWidget> {
  String _myString = '';

  @override
  Widget build(BuildContext context) {    
    return ElevatedButton(
      onLongPress: () {
        setState(() {
          _myString = 'data';
        });
      },
      child: Text(_myString),
    );
  }
}
''');
  }
}
