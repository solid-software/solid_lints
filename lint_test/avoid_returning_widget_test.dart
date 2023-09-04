// ignore_for_file: unused_element

/// Check returning a widget fail
/// `avoid_returning_widgets`

import 'package:flutter/material.dart';

// expect_lint: avoid_returning_widgets
Widget avoidReturningWidgets() => const SizedBox();

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  // expect_lint: avoid_returning_widgets
  Widget _test1() => const SizedBox();

  // expect_lint: avoid_returning_widgets
  Widget _test2() {
    return const SizedBox(
      child: SizedBox(),
    );
  }

  // expect_lint: avoid_returning_widgets
  Widget get _test3 => const SizedBox();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
