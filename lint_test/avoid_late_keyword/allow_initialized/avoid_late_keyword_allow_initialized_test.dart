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
  /// ignored_types: Animation
  late final Animation animation1;

  /// ignored_types: Animation
  late final animation2 = AnimationController();

  /// ignored_types: Animation
  late final animation3 = SubAnimationController();

  /// expect_lint: avoid_late_keyword
  late final ColorTween colorTween1;

  /// expect_lint: avoid_late_keyword
  late final colorTween2 = ColorTween();

  /// expect_lint: avoid_late_keyword
  late final colorTween3 = colorTween2;

  /// ignored_types: Animation
  late final AnimationController controller1;

  /// expect_lint: avoid_late_keyword
  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late final String field2;

  /// expect_lint: avoid_late_keyword
  late final String field3 = 'string';

  /// expect_lint: avoid_late_keyword
  late final field4;

  void test() {
    /// ignored_types: Animation
    late final Animation animation1;

    /// ignored_types: Animation
    late final animation2 = AnimationController();

    /// ignored_types: Animation
    late final animation3 = SubAnimationController();

    /// expect_lint: avoid_late_keyword
    late final ColorTween colorTween1;

    /// expect_lint: avoid_late_keyword
    late final colorTween2 = ColorTween();

    /// expect_lint: avoid_late_keyword
    late final colorTween3 = colorTween2;

    /// ignored_types: Animation
    late final AnimationController controller1;

    /// expect_lint: avoid_late_keyword
    late final local1 = 'string';

    /// expect_lint: avoid_late_keyword
    late final String local2;

    /// expect_lint: avoid_late_keyword
    late final String local4 = 'string';

    /// expect_lint: avoid_late_keyword
    late final local3;
  }
}
