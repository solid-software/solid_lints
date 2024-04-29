// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';

/// Test the avoid_debug_print_in_release
void avoidDebugPrintTest() {
  // expect_lint: avoid_debug_print_in_release
  debugPrint('');

  // expect_lint: avoid_debug_print_in_release
  final test = debugPrint;

  var test2;

  // expect_lint: avoid_debug_print_in_release
  test2 = debugPrint;

  test.call('test');

  // expect_lint: avoid_debug_print_in_release
  final test3 = debugPrint('');

  someOtherFunction();

  if (!kReleaseMode) {
    debugPrint('');

    final test = debugPrint;

    var test2;

    test2 = debugPrint;

    test.call('test');

    final test3 = debugPrint('');

    someOtherFunction();

    if (true) {
      debugPrint('');

      final test = debugPrint;

      var test2;

      test2 = debugPrint;

      test.call('test');

      final test3 = debugPrint('');
    }
  }
}

void someOtherFunction() {
  print('iii');
}
