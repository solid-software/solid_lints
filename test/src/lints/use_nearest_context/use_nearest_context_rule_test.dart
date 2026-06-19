import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:solid_lints/src/lints/use_nearest_context/use_nearest_context_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../lints/auto_test_lint_offsets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseNearestContextRuleTest);
  });
}

@reflectiveTest
class UseNearestContextRuleTest extends AnalysisRuleTest
    with AutoTestLintOffsets {
  @override
  void setUp() {
    rule = UseNearestContextRule();
    newPackage('flutter')..addFile('lib/material.dart', r'''
class BuildContext {
  BuildContext get context => this;
  Object? get size => null;
}
class Widget {}
void showModalBottomSheet({required BuildContext context, required Widget Function(BuildContext) builder}) {}
class Builder extends Widget {
  final Function builder;
  Builder({required this.builder});
}
abstract class Element implements BuildContext {
  State? findAncestorStateOfType<T>();
  @override
  BuildContext get context => this;
  @override
  Object? get size => null;
}
abstract class State {
  BuildContext get context;
}
class Future {
  static void microtask(void Function() callback) {}
}
''');
    super.setUp();

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name]),
    );
  }

  Future<void> test_reports_on_outer_context_usage() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  final outerContext = context;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext _) {
      final s = ${expectLint('outerContext')}.size;
      return Widget();
    },
  );
}
''');
  }

  Future<void> test_does_not_report_on_nearest_context_usage() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext innerContext) {
      final s = innerContext.size;
      return Widget();
    },
  );
}
''');
  }

  Future<void> test_does_not_report_on_property_of_other_object() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

class FalsePositiveTest {
  void build(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        final state = (innerContext as Element).findAncestorStateOfType<State>()!;
        final s = state.context.size;
        return Widget();
      },
    );
  }
}
''');
  }

  Future<void> test_reports_on_this_context_inside_builder() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

class FalsePositiveTest {
  BuildContext get context => throw '';

  void build(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        final s = this.${expectLint('context')}.size;
        return Widget();
      },
    );
  }
}
''');
  }

  Future<void>
  test_does_not_report_on_local_variable_assigned_from_nearest_context() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

class FalsePositiveTest {
  void build(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext innerContext) {
        final localContext = innerContext;
        final s = localContext.size;
        return Widget();
      },
    );
  }
}
''');
  }

  Future<void>
  test_reports_on_outer_builder_context_usage_in_nested_builder() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext outerBuilderCtx) {
      return Builder(
        builder: (BuildContext innerBuilderCtx) {
          final s = ${expectLint('outerBuilderCtx')}.size;
          return Widget();
        },
      );
    },
  );
}
''');
  }

  Future<void> test_reports_on_untyped_builder_parameter_usage() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      final s = ${expectLint('context')}.size;
      return Widget();
    },
  );
}
''');
  }

  Future<void> test_reports_on_outer_context_usage_in_async_callback() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext innerContext) {
      Future.microtask(() {
        final s = ${expectLint('context')}.size;
      });
      return Widget();
    },
  );
}
''');
  }

  Future<void>
  test_does_not_report_on_nearest_context_usage_in_async_callback() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext innerContext) {
      Future.microtask(() {
        final s = innerContext.size;
      });
      return Widget();
    },
  );
}
''');
  }

  Future<void> test_reports_on_constructor_parameter_usage_in_builder() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

class QuickFixBrokenTest {
  QuickFixBrokenTest(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext _) {
        final s = ${expectLint('context')}.size;
        return Widget();
      },
    );
  }
}
''');
  }

  Future<void> test_does_not_report_on_shadowed_parameter_name_usage() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      final s = context.size;
      return Widget();
    },
  );
}
''');
  }

  Future<void> test_reports_on_nullable_outer_context_usage() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

void showDialog(BuildContext? context) {
  showModalBottomSheet(
    context: context!,
    builder: (BuildContext _) {
      final s = ${expectLint('context')};
      return Widget();
    },
  );
}
''');
  }

  Future<void> test_reports_on_this_context_inside_extension_method() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  void someMethod() {
    showModalBottomSheet(
      context: this,
      builder: (BuildContext innerContext) {
        final s = ${expectLint('this')}.size;
        return Widget();
      },
    );
  }
}
''');
  }

  Future<void> test_does_not_report_on_this_context_outside_builder() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  void someMethod() {
    final s = this.size;
  }
}
''');
  }

  Future<void> test_does_not_report_on_nullable_nearest_context_usage() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext? innerContext) {
      final s = innerContext?.size;
      return Widget();
    },
  );
}
''');
  }

  Future<void>
  test_reports_on_outer_context_usage_with_nullable_nearest_context() async {
    await assertAutoDiagnostics('''
import 'package:flutter/material.dart';

void showDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext? innerContext) {
      final s = ${expectLint('context')}.size;
      return Widget();
    },
  );
}
''');
  }
}
