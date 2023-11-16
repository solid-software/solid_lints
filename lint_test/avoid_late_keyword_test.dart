// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

import 'package:flutter/material.dart';

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
class AvoidLateKeyword {
  late final ColorTween colorTween;

  late final AnimationController controller1;

  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late String field2;

  void test() {
    late final ColorTween colorTween;

    late final AnimationController controller2;

    late final field3 = 'string';

    /// expect_lint: avoid_late_keyword
    late String field4;
  }
}
