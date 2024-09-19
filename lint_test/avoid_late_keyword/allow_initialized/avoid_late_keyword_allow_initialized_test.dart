// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

abstract class Animation {}

class AnimationController implements Animation {}

class SubAnimationController extends AnimationController {}

class ColorTween {}

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
/// allow_initialized option disabled
class AvoidLateKeyword {
  /// expect_lint: avoid_late_keyword
  late final Animation animation1;

  late final animation2 = AnimationController();

  late final animation3 = SubAnimationController();

  /// expect_lint: avoid_late_keyword
  late final ColorTween colorTween1;

  late final colorTween2 = ColorTween();

  late final colorTween3 = colorTween2;

  /// expect_lint: avoid_late_keyword
  late final AnimationController controller1;

  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late final String field2;

  late final String field3 = 'string';

  /// expect_lint: avoid_late_keyword
  late final field4;

  void test() {
    /// expect_lint: avoid_late_keyword
    late final Animation animation1;

    late final animation2 = AnimationController();

    late final animation3 = SubAnimationController();

    /// expect_lint: avoid_late_keyword
    late final ColorTween colorTween1;

    late final colorTween2 = ColorTween();

    late final colorTween3 = colorTween2;

    /// expect_lint: avoid_late_keyword
    late final AnimationController controller1;

    late final local1 = 'string';

    /// expect_lint: avoid_late_keyword
    late final String local2;

    late final String local4 = 'string';

    /// expect_lint: avoid_late_keyword
    late final local3;
  }
}
