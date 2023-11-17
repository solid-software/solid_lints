// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
/// allow_initialized option disabled
class AvoidLateKeyword {
  /// expect_lint: avoid_late_keyword
  late final ColorTween colorTween;

  late final AnimationController controller1;

  /// expect_lint: avoid_late_keyword
  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late String field2;

  void test() {
    /// expect_lint: avoid_late_keyword
    late final ColorTween colorTween;
    
    late final AnimationController controller2;

    /// expect_lint: avoid_late_keyword
    late final field3 = 'string';

    /// expect_lint: avoid_late_keyword
    late String field4;
  }
}

abstract class Animation {}

class AnimationController implements Animation {}

class ColorTween {}