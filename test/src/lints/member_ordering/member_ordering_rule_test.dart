import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/member_ordering/member_ordering_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MemberOrderingRuleTest);
  });
}

@reflectiveTest
class MemberOrderingRuleTest extends AnalysisRuleTest with AutoTestLintOffsets {
  static const _defaultAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      member_ordering: {}
  ''';

  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      member_ordering:
        alphabetize: true
        order:
          - public_fields
          - private_fields
          - constructors
          - getters
          - setters
          - public_methods
          - private_methods
          - close_method
        widgets_order:
          - const_fields
          - static_fields
          - static_methods
          - public_fields
          - private_fields
          - public_methods
          - private_methods
          - constructors
          - build_method
          - init_state_method
          - did_change_dependencies_method
          - did_update_widget_method
          - dispose_method
  ''';

  static const _alphabetizeAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      member_ordering:
        alphabetize: true
        alphabetize_by_type: true
  ''';

  static const _customOrderAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      member_ordering:
        order:
          - public_methods
          - public_fields
  ''';

  static const _customWidgetsOrderAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      member_ordering:
        widgets_order:
          - build_method
          - init_state_method
  ''';

  static const _factoryOrderAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      member_ordering:
        order:
          - constructors
          - factory_constructors
          - public_fields
  ''';

  @override
  void setUp() {
    final flutter = newPackage('flutter');
    flutter.addFile('lib/src/widgets/framework.dart', r'''
class BuildContext {}
class Key {}
abstract class Widget {
  const Widget({Key? key});
}
abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});
  State createState();
}
abstract class State<T extends StatefulWidget> {
  void initState() {}
  void didChangeDependencies() {}
  void didUpdateWidget(T oldWidget) {}
  void dispose() {}
  Widget build(BuildContext context) => throw 0;
}
''');

    rule = MemberOrderingRule(
      analysisOptionsLoader: AnalysisOptionsLoader(
        resourceProvider: resourceProvider,
      ),
    );

    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_mockAnalysisOptionsContent),
    );
  }

  String _configWith(String pluginConfig) =>
      '''${analysisOptionsContent(rules: [rule.name])}
$pluginConfig''';

  Future<void> test_does_not_report_on_correct_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_defaultAnalysisOptionsContent),
    );
    await assertNoDiagnostics(r'''
class CorrectOrder {
  final publicField = 1;

  int get privateFieldGetter => 1;

  CorrectOrder();

  void publicDoStuff() {}
}
''');
  }

  Future<void> test_does_not_report_on_empty_class() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_defaultAnalysisOptionsContent),
    );
    await assertNoDiagnostics(r'''
class EmptyClass {}
''');
  }

  Future<void> test_does_not_report_on_single_member_class() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_defaultAnalysisOptionsContent),
    );
    await assertNoDiagnostics(r'''
class SingleMember {
  final a = 1;
}
''');
  }

  Future<void> test_reports_on_wrong_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_defaultAnalysisOptionsContent),
    );
    await assertAutoDiagnostics('''
class WrongOrder {
  void publicDoStuff() {}
  ${expectLint('WrongOrder();')}
}
''');
  }

  Future<void>
  test_does_not_report_on_non_alphabetical_order_by_default() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_defaultAnalysisOptionsContent),
    );
    await assertNoDiagnostics(r'''
class NonAlphabetical {
  final b = 1;
  final a = 1;
}
''');
  }

  Future<void> test_does_not_report_on_correct_widget_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_defaultAnalysisOptionsContent),
    );
    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class CorrectWidgetState extends State<StatefulWidget> {
  CorrectWidgetState();

  final finalField = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
''');
  }

  Future<void> test_reports_on_wrong_widget_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_defaultAnalysisOptionsContent),
    );
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class WrongWidgetState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
  }

  ${expectLint('WrongWidgetState();')}
}
''');
  }

  Future<void> test_reports_on_non_alphabetical_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_alphabetizeAnalysisOptionsContent),
    );

    await assertAutoDiagnostics('''
class AlphabeticalClass {
  final b = 1;
  ${expectLint('final a = 1;')}
}
''');
  }

  Future<void> test_reports_on_non_alphabetical_by_type_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_alphabetizeAnalysisOptionsContent),
    );

    await assertAutoDiagnostics('''
class AlphabeticalByTypeClass {
  int b = 1;
  ${expectLint('double a = 1.0;')}
}
''');
  }

  Future<void> test_does_not_report_on_correct_custom_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_customOrderAnalysisOptionsContent),
    );

    await assertNoDiagnostics(r'''
class CorrectOrder {
  void publicDoStuff() {}
  final publicField = 1;
}
''');
  }

  Future<void> test_reports_on_wrong_custom_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_customOrderAnalysisOptionsContent),
    );

    await assertAutoDiagnostics('''
class WrongOrder {
  final publicField = 1;
  ${expectLint('void publicDoStuff() {}')}
}
''');
  }

  Future<void> test_does_not_report_on_correct_custom_widgets_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_customWidgetsOrderAnalysisOptionsContent),
    );

    await assertNoDiagnostics(r'''
import 'package:flutter/src/widgets/framework.dart';

class CorrectWidgetState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) => throw 0;

  @override
  void initState() {
    super.initState();
  }
}
''');
  }

  Future<void> test_reports_on_wrong_custom_widgets_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_customWidgetsOrderAnalysisOptionsContent),
    );

    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class WrongWidgetState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
  }

  ${expectLint('@override Widget build(BuildContext context) => throw 0;')}
}
''');
  }

  Future<void>
  test_reports_on_non_alphabetical_fields_and_methods_order() async {
    await assertAutoDiagnostics('''
class AlphabeticalClass {
  final b = 1;

  ${expectLint('final a = 1;')}
  final c = 1;

  void bStuff() {}

  ${expectLint('void aStuff() {}')}

  void cStuff() {}

  void visitStatement() {}

  ${expectLint('void visitStanford() {}')}
}
''');
  }

  Future<void> test_reports_on_named_method_wrong_order() async {
    await assertAutoDiagnostics('''
class NamedMethodOrder {
  void close() {}

  ${expectLint('void publicDoStuff() {}')}
}
''');
  }

  Future<void> test_does_not_report_on_named_method_correct_order() async {
    await assertNoDiagnostics('''
class NamedMethodOrder {
  void publicDoStuff() {}

  void close() {}
}
''');
  }

  Future<void> test_does_not_report_on_correct_factory_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_factoryOrderAnalysisOptionsContent),
    );
    await assertNoDiagnostics(r'''
class FactoryOrder {
  FactoryOrder();

  factory FactoryOrder.create() => FactoryOrder();

  final field = 1;
}
''');
  }

  Future<void> test_reports_on_wrong_factory_order() async {
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      _configWith(_factoryOrderAnalysisOptionsContent),
    );
    await assertAutoDiagnostics('''
class FactoryOrder {
  factory FactoryOrder.create() => FactoryOrder();

  ${expectLint('FactoryOrder();')}

  final field = 1;
}
''');
  }

  Future<void>
  test_does_not_report_on_correct_order_with_custom_config() async {
    await assertNoDiagnostics('''
class CorrectOrder {
  final publicField = 1;
  int _privateField = 2;

  CorrectOrder();

  int get privateFieldGetter => _privateField;

  void set privateFieldSetter(int value) {
    _privateField = value;
  }

  void publicDoStuff() {}

  void _privateDoStuff() {}

  void close() {}
}
''');
  }

  Future<void> test_reports_on_wrong_order_with_custom_config() async {
    await assertAutoDiagnostics('''
class WrongOrder {
  void close() {}

  ${expectLint('void _privateDoStuff() {}')}

  ${expectLint('void publicDoStuff() {}')}

  ${expectLint('void set privateFieldSetter(int value) { _privateField = value; }')}

  ${expectLint('int get privateFieldGetter => _privateField;')}

  ${expectLint('WrongOrder();')}

  ${expectLint('int _privateField = 2;')}

  ${expectLint('final publicField = 1;')}
}
''');
  }

  Future<void>
  test_reports_on_partially_wrong_order_with_custom_config() async {
    await assertAutoDiagnostics('''
class PartiallyWrongOrder {
  final publicField = 1;

  PartiallyWrongOrder();

  ${expectLint('int _privateField = 2;')}

  int get privateFieldGetter => _privateField;

  void set privateFieldSetter(int value) {
    _privateField = value;
  }

  void _privateDoStuff() {}

  ${expectLint('void publicDoStuff() {}')}

  void close() {}
}
''');
  }

  Future<void>
  test_does_not_report_on_correct_widget_order_with_custom_config() async {
    await assertNoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class CorrectWidget extends StatefulWidget {
  @override
  State<CorrectWidget> createState() => _CorrectWidgetState();

  const CorrectWidget({super.key});
}

class _CorrectWidgetState extends State<CorrectWidget> {
  static const constField = 1;
  static final staticField = 1;

  static void staticDoStuff() {}

  final publicField = 1;
  final _privateField = 1;

  void publicDoStuff() {}

  void _privateDoStuff() {}

  _CorrectWidgetState();

  @override
  Widget build(BuildContext context) => throw 0;

  @override
  void initState() => super.initState();

  @override
  void didChangeDependencies() => super.didChangeDependencies();

  @override
  void didUpdateWidget(covariant CorrectWidget oldWidget) =>
      super.didUpdateWidget(oldWidget);

  @override
  void dispose() => super.dispose();
}
''');
  }

  Future<void> test_reports_on_wrong_widget_order_with_custom_config() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class WrongWidget extends StatefulWidget {
  const WrongWidget({super.key});

  ${expectLint('@override State<WrongWidget> createState() => _WrongWidgetState();')}
}

class _WrongWidgetState extends State<WrongWidget> {
  @override
  void dispose() => super.dispose();

  ${expectLint('@override void didUpdateWidget(covariant WrongWidget oldWidget) => super.didUpdateWidget(oldWidget);')}

  ${expectLint('@override void didChangeDependencies() => super.didChangeDependencies();')}

  ${expectLint('@override void initState() => super.initState();')}

  ${expectLint('@override Widget build(BuildContext context) => throw 0;')}

  ${expectLint('_WrongWidgetState();')}

  ${expectLint('void _privateDoStuff() {}')}

  ${expectLint('void publicDoStuff() {}')}

  ${expectLint('final _privateField = 1;')}

  ${expectLint('final publicField = 1;')}

  ${expectLint('static void staticDoStuff() {}')}

  ${expectLint('static final staticField = 1;')}

  ${expectLint('static const constField = 1;')}
}
''');
  }

  Future<void>
  test_reports_on_partially_correct_widget_order_with_custom_config() async {
    await assertAutoDiagnostics('''
import 'package:flutter/src/widgets/framework.dart';

class PartiallyCorrectWidget extends StatefulWidget {
  @override
  State<PartiallyCorrectWidget> createState() => _PartiallyCorrectWidgetState();

  const PartiallyCorrectWidget({super.key});
}

class _PartiallyCorrectWidgetState extends State<PartiallyCorrectWidget> {
  static final staticField = 1;

  ${expectLint('static const constField = 1;')}

  static void staticDoStuff() {}

  final _privateField = 1;

  ${expectLint('final publicField = 1;')}

  void publicDoStuff() {}

  void _privateDoStuff() {}

  _PartiallyCorrectWidgetState();

  @override
  Widget build(BuildContext context) => throw 0;

  @override
  void didChangeDependencies() => super.didChangeDependencies();

  ${expectLint('@override void initState() => super.initState();')}

  @override
  void didUpdateWidget(covariant PartiallyCorrectWidget oldWidget) =>
      super.didUpdateWidget(oldWidget);

  @override
  void dispose() => super.dispose();
}
''');
  }
}
