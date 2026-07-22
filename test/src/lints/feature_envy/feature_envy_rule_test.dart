import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/feature_envy/feature_envy_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FeatureEnvyRuleTest);
  });
}

@reflectiveTest
class FeatureEnvyRuleTest extends AnalysisRuleTest with AutoTestLintOffsets {
  static const _importFlutterWidgets = "import 'package:flutter/widgets.dart';";
  static const _mockFlutterWidgetsContent = '''
abstract class Widget {
  const Widget();
}

class StatelessWidget implements Widget {
  const StatelessWidget();
}

class StatefulWidget implements Widget {
  const StatefulWidget();
}

abstract class State<T extends StatefulWidget> {
  T get widget => throw 'unimplemented';
}
''';

  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      feature_envy:
        atfd_threshold: 2
        fdp_threshold: 5
  ''';

  @override
  void setUp() {
    rule = FeatureEnvyRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );
    newPackage('flutter')
      ..addFile('lib/widgets.dart', _mockFlutterWidgetsContent);
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      '''${analysisOptionsContent(rules: [rule.name])}
$_mockAnalysisOptionsContent''',
    );
  }

  Future<void> test_reports_when_atfd_exceeds_threshold() =>
      assertAutoDiagnostics('''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);

  int get area => width * height;
  int getArea() => width * height;
  void dummy() {}
}

class MathHelper {
  int ${expectLint('sumOfAreas')}(Rectangle r1, Rectangle r2) => (r1.width * r1.height) + (r2.width * r2.height);
}
''');

  Future<void> test_does_not_report_when_atfd_below_threshold() =>
      assertNoDiagnostics(r'''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
}

class MathHelper {
  int getWidth(Rectangle r1) => r1.width;
}
''');

  Future<void> test_reports_when_atfd_meets_threshold() =>
      assertAutoDiagnostics('''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
  int getArea() => width * height;
  void dummy() {}
}

class MathHelper {
  int ${expectLint('sumOfAreas')}(Rectangle r1, Rectangle r2) => r1.area + r2.area;
}
''');

  Future<void> test_reports_when_external_exceeds_internal() =>
      assertAutoDiagnostics('''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
  void dummy() {}
  void dummy2() {}
}

class NormalClass {
  int value = 0;
  
  void ${expectLint('doSomething')}(Rectangle rect) {
    print(rect.width);
    print(rect.height);
    print(rect.area);
  }
}
''');

  Future<void> test_does_not_report_when_internal_exceeds_external() =>
      assertNoDiagnostics(r'''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
}

class NormalClass {
  int value = 0;
  
  void doSomethingElse(Rectangle rect) {
    print(rect.width);
    print(rect.height);
    print(value);
    print(value);
    print(value);
  }
}
''');

  Future<void> test_reports_class_with_most_accesses() =>
      assertAutoDiagnostics('''
class Circle {
  final int radius;
  const Circle(this.radius);
  int get area => radius * radius;
  void dummy() {}
  void dummy2() {}
}

class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
  void dummy() {}
  void dummy2() {}
}

class MathHelper {
  int ${expectLint('sumOfAreas', name: 'feature_envy', messageContainsAll: ['Rectangle'])}(Rectangle r1, Rectangle r2, Circle c1) {
    return (r1.width * r1.height) + (r2.width * r2.height) + c1.area;
  }
}
''');

  Future<void> test_reports_when_accessing_inherited_methods() =>
      assertAutoDiagnostics('''
class BaseExternal {
  int get baseValue => 1;
  void dummy() {}
}

class External extends BaseExternal {
  int get childValue => 2;
}

class MyClass {
  int ${expectLint('doSomething')}(External ext) {
    return ext.baseValue + ext.childValue;
  }
}
''');

  Future<void> test_reports_when_using_fields_as_targets() =>
      assertAutoDiagnostics('''
class External {
  void step1() {}
  void step2() {}
  void step3() {}
}

class MyClass {
  final External myField = External();
  
  void ${expectLint('doSomething')}() {
    myField.step1();
    myField.step2();
    myField.step3();
  }
}
''');

  Future<void> test_reports_when_using_fields_with_this_as_targets() =>
      assertAutoDiagnostics('''
class External {
  void step1() {}
  void step2() {}
  void step3() {}
}

class MyClass {
  final External myField = External();
  
  void ${expectLint('doSomething')}() {
    this.myField.step1();
    this.myField.step2();
    this.myField.step3();
  }
}
''');

  Future<void> test_reports_with_cascades() => assertAutoDiagnostics('''
class External {
  void step1() {}
  void step2() {}
  void step3() {}
}

class MyClass {
  final External myField = External();
  
  void ${expectLint('doSomething')}() {
    myField..step1()..step2()..step3();
  }
}
''');

  Future<void> test_reports_with_cascaded_assignments() =>
      assertAutoDiagnostics('''
class External {
  int value1 = 0;
  int value2 = 0;
  int value3 = 0;
  void dummy1() {}
  void dummy2() {}
  void dummy3() {}
}

class MyClass {
  final External myField = External();
  
  void ${expectLint('doSomething')}() {
    myField..value1 = 1..value2 = 2..value3 = 3;
  }
}
''');

  Future<void> test_reports_when_accessing_nested_foreign_fields() =>
      assertAutoDiagnostics('''
class DeepService {
  void execute() {}
}

class Middleware {
  final DeepService service = DeepService();
}

class Client {
  final Middleware middleware = Middleware();
}

class MyClass {
  void ${expectLint('process')}(Client client) {
    client.middleware.service.execute();
    client.middleware.service.execute();
    client.middleware.service.execute();
  }
}
''');

  Future<void> test_reports_with_operator_overloads() =>
      assertAutoDiagnostics('''
class Vector {
  int x;
  int y;
  Vector(this.x, this.y);
  
  Vector operator +(Vector other) => Vector(x + other.x, y + other.y);
}

class MathProcessor {
  void ${expectLint('process')}(Vector v1, Vector v2, Vector v3) {
    final result = v1 + v2 + v3;
    print(result.x);
  }
}
''');

  Future<void> test_patterns_threshold_2() => assertAutoDiagnostics('''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  void dummy() {}
}

class MathHelper {
  void ${expectLint('doSomething')}(Rectangle r) {
    if (r case Rectangle(:final height, :final width)) {
      print(height);
    }
  }
}
''');

  Future<void> test_patterns_no_diagnostic_below_threshold() =>
      assertNoDiagnostics('''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
}

class MathHelper {
  void doSomething(Rectangle r) {
    if (r case Rectangle(:final height)) {
      print(height);
    }
  }
}
''');

  Future<void> test_patterns_explicit_no_diagnostic_below_threshold() =>
      assertNoDiagnostics('''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
}

class MathHelper {
  void doSomething(Rectangle r) {
    if (r case Rectangle(height: final h)) {
      print(h);
    }
  }
}
''');

  Future<void> test_index_assignment_should_trigger_lint() =>
      assertAutoDiagnostics('''
class MyList {
  int operator [](int index) => 0;
  void operator []=(int index, int value) {}
}

class MathHelper {
  void ${expectLint('doSomething')}(MyList list) {
    list[0] = 5;
    list[1] = 6;
  }
}
''');

  Future<void> test_compound_index_assignment_should_trigger_lint() =>
      assertAutoDiagnostics('''
class MyList {
  int operator [](int index) => 0;
  void operator []=(int index, int value) {}
}

class MathHelper {
  void ${expectLint('doSomething')}(MyList list) {
    list[0] += 5;
    list[0] += 6;
  }
}
''');

  Future<void> test_static_member_accesses_ignored() => assertNoDiagnostics('''
class External {
  static int value = 0;
  static void staticMethod() {}
}

class MathHelper {
  void doSomething() {
    External.value = 5;
    External.staticMethod();
    External.staticMethod();
  }
}
''');

  Future<void> test_constructor_invocations_ignored() => assertNoDiagnostics('''
class External {
  const External();
}

class MathHelper {
  void doSomething() {
    final e1 = External();
    final e2 = External();
    final e3 = const External();
  }
}
''');

  Future<void> test_extension_override_on_this_internal() =>
      assertNoDiagnostics('''
extension MyExtension on MathHelper {
  void extMethod() {}
}

class MathHelper {
  void doSomething() {
    MyExtension(this).extMethod();
    MyExtension(this).extMethod();
  }
}
''');

  Future<void> test_explicit_extension_override_on_external_target() =>
      assertAutoDiagnostics('''
extension MyExtension on Rectangle {
  void extMethod() {}
}

class Rectangle {
  final int width;
  final int height;
  const Rectangle(this.width, this.height);
  void dummy() {}
  void dummy2() {}
}

class MathHelper {
  void ${expectLint('doSomething')}(Rectangle r) {
    MyExtension(r).extMethod();
    MyExtension(r).extMethod();
  }
}
''');

  Future<void> test_default_threshold_is_four() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name]),
    );

    await assertNoDiagnostics(r'''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
}

class MathHelper {
  void doSomething(Rectangle r) {
    print(r.width);
    print(r.height);
    print(r.area);
  }
}
''');

    await assertAutoDiagnostics(r'''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
  int getArea() => width * height;
}

class MathHelper {
  void ${expectLint('doSomething')}(Rectangle r) {
    print(r.width);
    print(r.height);
    print(r.area);
    print(r.getArea());
  }
}
''');
  }

  Future<void> test_does_not_count_accesses_in_closures() =>
      assertNoDiagnostics(r'''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
}

class MathHelper {
  void doSomething(List<Rectangle> list) {
    list.forEach((r) {
      print(r.width);
      print(r.height);
      print(r.width);
    });
  }
}
''');

  Future<void> test_does_not_count_accesses_in_nested_functions() =>
      assertNoDiagnostics(r'''
class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
}

class MathHelper {
  void doSomething(Rectangle r) {
    void helper() {
      print(r.width);
      print(r.height);
      print(r.width);
    }
    helper();
  }
}
''');

  Future<void> test_does_not_report_on_widgets_and_states() =>
      assertNoDiagnostics('''
$_importFlutterWidgets

class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
}

class MyWidget extends StatelessWidget {
  Widget build(Rectangle r) {
    print(r.width);
    print(r.height);
    print(r.width);
    return MyWidget();
  }
}

class MyWidgetState extends State {
  void doSomething(Rectangle r) {
    print(r.width);
    print(r.height);
    print(r.width);
  }
}
''');

  Future<void> test_reports_on_cascades_of_instance_creation() =>
      assertAutoDiagnostics('''
class External {
  void step1() {}
  void step2() {}
  void step3() {}
}

class MyClass {
  void ${expectLint('doSomething')}() {
    External()..step1()..step2()..step3();
  }
}
''');

  Future<void> test_profile_notifier_mimic() => assertNoDiagnostics(r'''
class Model {
  final String field1;
  final String field2;

  const Model({
    required this.field1,
    required this.field2,
  });
}

class Service {
  Model? get model => null;
}

class PageNotifier {
  String _val1 = '';
  String _val2 = '';

  void updateFromModel(Service service) {
    final data = service.model;
    if (data == null) return;

    _val1 = data.field1;
    _val2 = data.field2;
  }
}
''');

  Future<void> test_custom_laa_and_fdp_thresholds() async {
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
plugins:
  solid_lints:
    rules:
      - feature_envy
    diagnostics:
      feature_envy:
        atfd_threshold: 2
        laa_threshold: 0.33
        fdp_threshold: 1
''');

    await assertNoDiagnostics(r'''
class External {
  void method1() {}
  void method2() {}
  void method3() {}
}

class Notifier {
  int val = 0;
  void update(External ext) {
    ext.method1();
    ext.method2();
    ext.method3();
    val = 1;
    val = 2;
  }
}
''');

    await assertNoDiagnostics(r'''
class External1 {
  void method1() {}
  void method2() {}
}

class External2 {
  void method3() {}
}

class Notifier {
  void update(External1 ext1, External2 ext2) {
    ext1.method1();
    ext1.method2();
    ext2.method3();
  }
}
''');
  }

  Future<void> test_simple_assignment_does_not_double_count() =>
      assertNoDiagnostics(r'''
class External {
  int value = 0;
}

class MyClass {
  void doSomething(External ext) {
    ext.value = 5;
  }
}
''');

  Future<void> test_does_not_report_on_data_class_accesses() =>
      assertNoDiagnostics(r'''
class DataClass {
  final int a;
  final int b;
  const DataClass(this.a, this.b);

  @override
  String toString() => '$a, $b';

  @override
  bool operator ==(Object other) => other is DataClass && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);
}

class MyClass {
  void doSomething(DataClass data) {
    print(data.a);
    print(data.b);
    print(data.a);
    print(data.b);
  }
}
''');

  Future<void> test_reports_on_non_data_class_accesses() =>
      assertAutoDiagnostics('''
class NormalClass {
  final int a;
  final int b;
  const NormalClass(this.a, this.b);

  void customMethod() {}
}

class MyClass {
  void ${expectLint('doSomething')}(NormalClass normal) {
    print(normal.a);
    print(normal.b);
    print(normal.a);
    print(normal.b);
  }
}
''');

  Future<void>
  test_reports_envy_when_accesses_spread_across_multiple_classes() async {
    await assertAutoDiagnostics('''
class Circle {
  final int radius;
  const Circle(this.radius);
  int get area => radius * radius;
  void dummy() {}
}

class Rectangle {
  final int height;
  final int width;
  const Rectangle(this.height, this.width);
  int get area => width * height;
  void dummy() {}
  void dummy2() {}
}

class MathHelper {
  int value = 0;
  
  int ${expectLint('sumOfAreas')}(Rectangle r, Circle c) {
    value = 1;
    return r.width + r.height + c.radius + c.area;
  }
}
''');
  }

  Future<void> test_implicit_extension_override_on_this_internal() =>
      assertNoDiagnostics(r'''
extension MyExtension on MathHelper {
  void extMethod() {}
}

class Rectangle {
  final int width;
  final int height;
  const Rectangle(this.width, this.height);
}

class MathHelper {
  void doSomething(Rectangle r) {
    extMethod();
    extMethod();
    print(r.width);
    print(r.height);
  }
}
''');

  Future<void> test_reports_intermediate_external_accesses_correctly() =>
      assertAutoDiagnostics('''
class External1 {
  final External2 ext2;
  const External1(this.ext2);
  void customMethod1() {}
}

class External2 {
  final int value;
  const External2(this.value);
  void customMethod2() {}
}

class MathHelper {
  void ${expectLint('doSomething', name: 'feature_envy', messageContainsAll: ['External1'])}(External1 ext1) {
    print(ext1.ext2.value);
    print(ext1.ext2.value);
  }
}
''');
}
