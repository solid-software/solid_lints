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
}

void someOtherFunction() {
  print('iii');
}
