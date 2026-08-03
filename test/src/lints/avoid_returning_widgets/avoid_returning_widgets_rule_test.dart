import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';
import 'package:solid_lints/src/lints/avoid_returning_widgets/avoid_returning_widgets_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../utils/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidReturningWidgetsRuleTest);
  });
}

@reflectiveTest
class AvoidReturningWidgetsRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  static const _importFlutterWidgets = "import 'package:flutter/widgets.dart';";
  static const _mockFlutterWidgetsContent = '''
abstract class Widget {
  final String key;

  const Widget({required this.key});
}

class StatelessWidget implements Widget {
  const StatelessWidget({super.key});

  @override
  Widget build(BuildContext context);
}

class StatefulWidget implements Widget {
  const StatefulWidget({super.key});
  
  @override
  Widget build(BuildContext context);
}

abstract interface class BuildContext {}

class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) => throw 'unimplemented';
}

class SizedBox extends Widget {
  final Widget? child;

  const SizedBox({this.child});

  @override
  Widget build(BuildContext context) => child ?? const SizedBox();
}

class BoxDecoration extends Widget {
  const BoxDecoration();

  @override
  Widget build(BuildContext context) => throw 'unimplemented';
}

abstract class State<T extends StatefulWidget> {
  T get widget => throw 'unimplemented';
}

class Color {}

abstract interface class WidgetStateProperty<T> {}

class WidgetStateColor extends Color implements WidgetStateProperty<Color> {}

class DecoratedBox extends Widget {
  const DecoratedBox({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) => throw 'unimplemented';
}
''';
  static const _mockAnalysisOptionsContent = '''
plugins:
  solid_lints:
    diagnostics:
      avoid_returning_widgets:
        exclude:
          - class_name: ExcludeWidget 
            method_name: excludeWidgetMethod
          - method_name: excludeMethod
  ''';

  void _addBaseWidgetFile() {
    newFile('$testPackageLibPath/base_widget.dart', '''
$_importFlutterWidgets
class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key});

  Widget get box => SizedBox();

  Widget decoratedBox() => DecoratedBox(decoration: BoxDecoration());

  set box(Widget value) {
    throw 'unimplemented';
  }
}
''');
  }

  @override
  void setUp() {
    rule = AvoidReturningWidgetsRule(
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

  Future<void> test_reports_on_static_function() async {
    await assertAutoDiagnostics('''
$_importFlutterWidgets

${expectLint('Widget avoidReturningWidgets() => const SizedBox();')}

${expectLint('''Widget build() {
  return SizedBox();
}''')}
''');
  }

  Future<void> test_reports_on_methods() async {
    await assertAutoDiagnostics('''
$_importFlutterWidgets

class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key});

  ${expectLint('''Widget decoratedBox() {
    return DecoratedBox(decoration: BoxDecoration());
  }''')}
}
''');
  }

  Future<void> test_reports_on_getters_but_not_setters() async {
    await assertAutoDiagnostics('''
$_importFlutterWidgets

class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key});

  ${expectLint('Widget get box => SizedBox();')}

  set box(Widget value) {
    throw 'unimplemented';
  }
}
''');
  }

  Future<void> test_reports_on_private_members() async {
    _addBaseWidgetFile();

    await assertAutoDiagnostics('''
$_importFlutterWidgets
import 'base_widget.dart';

class MyWidget extends BaseWidget {
  const MyWidget({super.key});

  ${expectLint('Widget _test1() => const SizedBox();')}

  ${expectLint('''Widget _test2() {
    return const SizedBox(
      child: SizedBox(),
    );
  }''')}

  ${expectLint('Widget get _test3 => const SizedBox();')}

  @override
  Widget decoratedBox() {
    return super.decoratedBox();
  }

  @override
  Widget get box => SizedBox();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
''');
  }

  Future<void> test_does_not_report_on_overridden_members() async {
    _addBaseWidgetFile();

    // Shouldn't report even if not annotated with @override
    await assertNoDiagnostics('''
$_importFlutterWidgets
import 'base_widget.dart';

class MyWidget extends BaseWidget {
  const MyWidget({super.key});

  Widget decoratedBox() {
    return super.decoratedBox();
  }

  Widget get box => SizedBox();
  
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
''');
  }

  Future<void> test_does_not_report_on_excluded() async {
    await assertNoDiagnostics('''
$_importFlutterWidgets

SizedBox excludeMethod() => const SizedBox();

class ExcludeWidget extends StatelessWidget {
  const ExcludeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget excludeWidgetMethod() => const SizedBox();
}
''');
  }

  Future<void> test_reports_on_non_matching_excluded() async {
    await assertAutoDiagnostics('''
$_importFlutterWidgets

SizedBox excludeMethod() => const SizedBox();

class ExcludeWidget extends StatelessWidget {
  const ExcludeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  ${expectLint('Widget notExcludeWidgetMethod() => const Placeholder();')}
}

class NotExcludeWidget extends StatelessWidget {
  const NotExcludeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  ${expectLint('Widget excludeWidgetMethod() => const SizedBox();')}
}
''');
  }

  Future<void> test_does_not_report_on_collections() async {
    await assertNoDiagnostics('''
$_importFlutterWidgets

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  List<Widget> buildList() => [const SizedBox()];

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
''');
  }

  Future<void> test_does_not_report_on_non_widget_types() async {
    await assertNoDiagnostics('''
$_importFlutterWidgets

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  WidgetStateColor getColor() => WidgetStateColor();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
''');
  }

  Future<void> test_does_not_report_on_abstract_methods() async {
    await assertNoDiagnostics('''
$_importFlutterWidgets

abstract class BaseStrategy {
  Widget buildHeader(BuildContext context);
}
''');
  }

  Future<void> test_does_not_report_on_state_widget_getters() async {
    await assertNoDiagnostics('''
$_importFlutterWidgets

class TargetWidget extends StatefulWidget {
  const TargetWidget({super.key});
}

class _TargetWidgetState extends State<StatefulWidget> {
  TargetWidget get widget => super.widget as TargetWidget;
  TargetWidget get parenthesizedWidget => ((super.widget as TargetWidget));
  TargetWidget get blockWidget {
    return super.widget as TargetWidget;
  }
}
''');
  }

  Future<void> test_does_not_report_on_inline_builder_callbacks() async {
    await assertNoDiagnostics('''
$_importFlutterWidgets

void acceptBuilder(Widget Function(BuildContext) builder) {}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    acceptBuilder((ctx) => const SizedBox());
    return const SizedBox();
  }
}
''');
  }
}
