// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unnecessary_cast
// ignore_for_file: unused_field
// ignore_for_file: unused_element
// ignore_for_file: unused_local_variable

import 'package:flutter/widgets.dart';

/// Check the `member-ordering` rule

class A {
  int _a = 1;

  // expect_lint: member-ordering
  final b = 2;

  // Allowed because it's before constructor according to config
  set a(int value) => _a = value;

  // expect_lint: member-ordering
  A();

  void close() {}

  // should be before close-method
  // expect_lint: member-ordering
  int get a => _a;
}

class AWidget extends StatefulWidget {
  const AWidget({super.key});

  @override
  State<AWidget> createState() => _AWidgetState();
}

class _AWidgetState extends State<AWidget> {
  final _aWidgetDouble = 1;

  // should be before private-fields
  // expect_lint: member-ordering
  final aWidgetInt = 1;

  // should be before public-fields
  // expect_lint: member-ordering
  static double staticGetDouble() => 0.0;

  // should be before public-fields
  // expect_lint: member-ordering
  static const _aWidgetString = 'AWidget';

  void _privateDoStuff() {}

  // should be before private-methods
  // expect_lint: member-ordering
  void doStuff() {}

  // should be before public-methods
  // expect_lint: member-ordering
  static final aWidgetString = 'AWidget';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  // should be before did-update-widget
  // expect_lint: member-ordering
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // should be before init-state
  // expect_lint: member-ordering
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
