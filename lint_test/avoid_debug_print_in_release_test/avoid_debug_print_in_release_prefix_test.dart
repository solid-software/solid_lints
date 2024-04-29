// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart' as f;

/// Test the avoid_debug_print_in_release
void avoidDebugPrintTest() {
  // expect_lint: avoid_debug_print_in_release
  f.debugPrint('');

  // expect_lint: avoid_debug_print_in_release
  final test = f.debugPrint;

  test('test');

  // expect_lint: avoid_debug_print_in_release
  final test2 = f.debugPrint('');

  debugPrint();

  debugPrint;

  if (!f.kReleaseMode) {
    f.debugPrint('');

    final test = f.debugPrint;

    var test2;

    test2 = debugPrint;

    test.call('test');

    final test3 = f.debugPrint('');

    if (true) {
      f.debugPrint('');

      final test = f.debugPrint;

      var test2;

      test2 = debugPrint;

      test.call('test');

      final test3 = f.debugPrint('');
    }
  }
}

void debugPrint() {
  return;
}
