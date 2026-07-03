import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:solid_lints/src/lints/avoid_unused_parameters/avoid_unused_parameters_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/fake_analysis_options_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnusedParametersRuleTest);
  });
}

@reflectiveTest
class AvoidUnusedParametersRuleTest extends AnalysisRuleTest {
  static const _importFlutterMaterial =
      "import 'package:flutter/material.dart';";

  static const _mockFlutterMaterialContent = '''
abstract class Widget {
  final Object? key;

  const Widget({this.key});
}

class StatelessWidget implements Widget {
  const StatelessWidget({super.key});

  Widget build(BuildContext context);
}

abstract interface class BuildContext {}

class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) => throw 'unimplemented';
}
''';

  @override
  void setUp() {
    final FakeAnalysisOptionsLoader fakeAnalysisOptionsLoader =
        FakeAnalysisOptionsLoader(
          ruleOptions: {
            'exclude': [
              {'class_name': 'Exclude', 'method_name': 'excludeMethod'},
              {'method_name': 'excludeMethod'},
              'simpleMethodName',
              'SimpleClassName',
              'exclude',
            ],
            'exclude_annotation': ['freezed'],
          },
        );

    rule = AvoidUnusedParametersRule(
      analysisOptionsLoader: fakeAnalysisOptionsLoader,
    );
    newPackage('flutter')
      ..addFile('lib/material.dart', _mockFlutterMaterialContent);
    super.setUp();
  }

  Future<void> test_reports_on_unused_function_expression_parameters() async {
    await assertDiagnostics(
      r'''
typedef MaxFun = int Function(int a, int b);

final MaxFun bad = (int a, int b) => 1;

final MaxFun tetsFun = (int a, int b) {
  return 4;
};

var c = (String g) {
  return '0';
};

final MaxFun maxFunInstance = (int a, int b) => 1;
''',
      [
        lint(66, 5),
        lint(73, 5),
        lint(111, 5),
        lint(118, 5),
        lint(152, 8),
        lint(213, 5),
        lint(220, 5),
      ],
    );
  }

  Future<void> test_reports_on_unused_optional_and_named_parameters() async {
    await assertDiagnostics(
      r'''
final optional = (int a, [int b = 0]) {
  return a;
};

final named = (int a, {required int b, int c = 0}) {
  return c;
};
''',
      [lint(26, 9), lint(71, 5)],
    );
  }

  Future<void> test_reports_on_unused_top_level_functions() async {
    await assertDiagnostics(
      r'''
void fun(String s) {
  return;
}

void fun2(String s) {
  return;
}

void closure(int a) {
  void internal(int a) {
    print(a);
  }
}
''',
      [lint(9, 8), lint(44, 8), lint(82, 5)],
    );
  }

  Future<void> test_reports_on_unused_parameters_in_methods() async {
    await assertDiagnostics(
      r'''
class TestClass {
  static void staticMethod(int a) {}

  void method(String s) {
    return;
  }
}

class SomeOtherClass {
  final MaxFun maxFunLint = (int a, int b) => 1;

  // Good
  final MaxFun good = (int a, int b) {
    return a * b;
  };

  void method(String s) {
    return;
  }
}

typedef MaxFun = int Function(int a, int b);

class SomeOtherAnotherClass {
  void method(String s) {
    print(s);
    return;
  }

  void anonymousCallback(Function(int a) cb) {}
}
''',
      [
        lint(45, 5),
        lint(70, 8),
        lint(153, 5),
        lint(160, 5),
        lint(261, 8),
        lint(450, 18),
      ],
    );
  }

  Future<void> test_reports_on_unused_parameters_in_constructors() async {
    await assertDiagnostics(
      r'''
class Foo {
  final int a;
  final int? b;

  Foo.another({required int c})
      : a = 1,
        b = 0;

  factory Foo.aOnly(int a) {
    return Foo._(1, null);
  }

  Foo._(this.a, this.b);
}
''',
      [lint(59, 14), lint(127, 5)],
    );
  }

  Future<void> test_reports_on_unused_widget_constructor_parameters() async {
    await assertDiagnostics(
      '''
$_importFlutterMaterial

class TestWidget extends StatelessWidget {
  const TestWidget({
    super.key,
    int a = 1,
    String k = '',
  });

  factory TestWidget.a([int b = 0]) {
    return const TestWidget();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''',
      [lint(124, 9), lint(139, 13), lint(185, 9)],
    );
  }

  Future<void> test_does_not_report_on_used_parameters() async {
    await assertNoDiagnostics(r'''
typedef MaxFun = int Function(int a, int b);

final MaxFun good = (int a, int b) => a + b;

final MaxFun goodMax = (int a, int b) {
  return a + b;
};

String Function(String g) k = (String g) {
  return g;
};

void someOtherFunction(String s) {
  print(s);
}
''');
  }

  Future<void> test_does_not_report_on_underscore_parameters() async {
    await assertNoDiagnostics(r'''
typedef MaxFun = int Function(int a, int b);

final MaxFun good = (int a, _) => a;

final MaxFun ok = (int _, int __) => 1;

final MaxFun m = (_, __) => 1;

class TestClass {
  void methodWithUnderscores(int _) {}
}

class TestClass2 {
  void method(String _) {
    return;
  }
}
''');
  }

  Future<void> test_does_not_report_on_named_parameters() async {
    await assertNoDiagnostics(r'''
typedef Named = String Function({required String text});

final Named _named = ({required text}) {
  return '';
};

void ch({String text = ''}) {}

final Named _named2 = ({required text}) {
  return text;
};

final Named _named3 = ({required text}) => '';

final Named _named4 = ({required text}) => text;

void testNamed() {
  SomeAnotherClass(
    func: ({required text}) {},
  );
}

typedef ReqNamed = void Function({required String text});

class SomeAnotherClass {
  final ReqNamed func;

  SomeAnotherClass({
    required this.func,
  });
}
''');
  }

  Future<void>
  test_does_not_report_on_override_and_field_formal_parameters() async {
    await assertNoDiagnostics(r'''
class Foo {
  final int a;
  final int? b;

  Foo.name(this.a, this.b);

  Foo.coolName({required this.a, required this.b});

  Foo._(this.a, this.b);
}

class Bar extends Foo {
  Bar.name(super.a, super.b) : super.name();
}

class SomeAnotherClass extends SomeOtherClass {
  @override
  void method(String s) {}
}

class SomeOtherClass {
  void method(String s) {
    print(s);
  }
}

class UsingConstructorParameterInInitializer {
  final int _value;

  UsingConstructorParameterInInitializer(int value) : _value = value;

  void printValue() {
    print(_value);
  }
}
''');
  }

  Future<void> test_does_not_report_on_excluded_declarations() async {
    await assertNoDiagnostics(r'''
void excludeMethod(String s) {
  return;
}

void simpleMethodName(String s) {
  return;
}

class Exclude {
  void excludeMethod(String s) {
    return;
  }
}

class SimpleClassName {
  void simpleMethodName(String s) {
    return;
  }
}
''');
  }

  Future<void> test_reports_on_non_matching_excluded_declarations() async {
    await assertDiagnostics(
      r'''
class Exclude {
  void excludeMethod2(String s) {
    return;
  }
}

class SimpleClassName {
  void simpleMethodName2(String s) {
    return;
  }
}
''',
      [lint(38, 8), lint(118, 8)],
    );
  }

  Future<void>
  test_does_not_report_on_redirecting_factory_constructors() async {
    await assertNoDiagnostics(r'''
class RedirectingClass {
  const factory RedirectingClass({required int parameter}) = _RedirectingClass;
}

class _RedirectingClass implements RedirectingClass {
  final int parameter;
  const _RedirectingClass({required this.parameter});
}
''');
  }

  Future<void> test_does_not_report_on_freezed_classes() async {
    await assertNoDiagnostics(r'''
const freezed = Object();

@freezed
class Test {
  const factory Test({
    bool test,
  }) = _Test;
}

class _Test implements Test {
  final bool? test;
  const _Test({this.test});
}
''');
  }

  Future<void> test_does_not_report_on_excluded_declaration_and_annotation_single_string() async {
    final FakeAnalysisOptionsLoader fakeAnalysisOptionsLoader =
        FakeAnalysisOptionsLoader(
          ruleOptions: {
            'exclude': 'excludeMethod',
            'exclude_annotation': 'freezed',
          },
        );

    rule = AvoidUnusedParametersRule(
      analysisOptionsLoader: fakeAnalysisOptionsLoader,
    );

    await assertNoDiagnostics(r'''
const freezed = Object();

@freezed
class Test {
  const factory Test({
    bool test,
  }) = _Test;
}

class _Test implements Test {
  final bool? test;
  const _Test({this.test});
}

void excludeMethod(String s) {
  return;
}
''');
  }
}
