// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';

/// Test the avoid_debug_print
void avoidDebugPrintTest() {
  // expect_lint: avoid_debug_print
  debugPrint('');

  // expect_lint: avoid_debug_print
  final test = debugPrint;

  var test2;

  // expect_lint: avoid_debug_print
  test2 = debugPrint;

  test.call('test');

  // expect_lint: avoid_debug_print
  final test3 = debugPrint('');

  someOtherFunction();
}

void someOtherFunction() {
  print('iii');
}
