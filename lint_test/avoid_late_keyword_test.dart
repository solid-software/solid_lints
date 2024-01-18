// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

class ColorTween {}

class AnimationController {}

class SubAnimationController extends AnimationController {}

class NotAllowed {}

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
/// allow_initialized option enabled
class AvoidLateKeyword {
  late final ColorTween colorTween;

  late final AnimationController controller1;

  late final SubAnimationController controller2;

  late final controller3 = AnimationController();

  late final controller4 = SubAnimationController();

  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late final String field2;

  /// expect_lint: avoid_late_keyword
  late final field3;

  /// expect_lint: avoid_late_keyword
  late final NotAllowed na1;

  late final na2 = NotAllowed();

  void test() {
    late final ColorTween colorTween;

    late final AnimationController controller1;

    late final SubAnimationController controller2;

    late final controller3 = AnimationController();

    late final controller4 = SubAnimationController();

    late final local1 = 'string';

    /// expect_lint: avoid_late_keyword
    late final String local2;

    /// expect_lint: avoid_late_keyword
    late final local3;

    /// expect_lint: avoid_late_keyword
    late final NotAllowed na1;

    late final na2 = NotAllowed();
  }
}
