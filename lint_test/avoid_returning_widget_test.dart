// ignore_for_file: unused_element, prefer_match_file_name
// ignore_for_file: member_ordering

/// Check returning a widget fail
/// `avoid_returning_widgets`

import 'package:flutter/material.dart';

// expect_lint: avoid_returning_widgets
Widget avoidReturningWidgets() => const SizedBox();

class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key});

  // expect_lint: avoid_returning_widgets
  Widget get box => SizedBox();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MyWidget extends BaseWidget {
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
  Widget get box => ColoredBox(color: Colors.pink);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

// expect_lint: avoid_returning_widgets
Widget build() {
  return Offstage();
}
