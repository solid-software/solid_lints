// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unnecessary_cast
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
