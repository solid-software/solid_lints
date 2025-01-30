// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

class ColorTween {}

class AnimationController {}

class SubAnimationController extends AnimationController {}

class Allowed {}

class NotAllowed {}

class Subscription<T> {}

class ConcreteTypeWithNoGenerics {}

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
/// allow_initialized option enabled
class AvoidLateKeyword {
  /// ignored_types: ColorTween
  late final ColorTween colorTween;

  /// ignored_types: AnimationController
  late final AnimationController controller1;

  /// ignored_types: AnimationController
  late final SubAnimationController controller2;

  /// ignored_types: AnimationController
  late final controller3 = AnimationController();

  /// ignored_types: AnimationController
  late final controller4 = SubAnimationController();

  /// allow_initialized: true
  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late final String field2;

  /// expect_lint: avoid_late_keyword
  late final field3;

  /// expect_lint: avoid_late_keyword
  late final NotAllowed na1;

  /// allow_initialized: true
  late final a = Allowed();

  /// expect_lint: avoid_late_keyword
  late final Subscription<String> subscription1;

  /// ignored_types: Subscription<ConcreteTypeWithNoGenerics>
  late final Subscription<ConcreteTypeWithNoGenerics> subscription2;

  /// ignored_types: Subscription<List<Object?>>
  late final Subscription<List<String>> subscription3;

  /// ignored_types: Subscription<List<Object?>>
  late final Subscription<List<List<int>>> subscription4;

  /// ignored_types: Subscription<Map<dynamic, String>>
  late final Subscription<Map<dynamic, String>> subscription5;

  /// ignored_types: Subscription<Map<dynamic, String>>
  late final Subscription<Map<String, String>> subscription6;

  /// expect_lint: avoid_late_keyword
  late final Subscription<Map<String, dynamic>> subscription7;

  void test() {
    /// ignored_types: ColorTween
    late final ColorTween colorTween;

    /// ignored_types: AnimationController
    late final AnimationController controller1;

    /// ignored_types: AnimationController
    late final SubAnimationController controller2;

    /// ignored_types: AnimationController
    late final controller3 = AnimationController();

    /// ignored_types: AnimationController
    late final controller4 = SubAnimationController();

    /// allow_initialized: true
    late final local1 = 'string';

    /// expect_lint: avoid_late_keyword
    late final String local2;

    /// expect_lint: avoid_late_keyword
    late final local3;

    /// expect_lint: avoid_late_keyword
    late final NotAllowed na1;

    /// allow_initialized: true
    late final a = Allowed();

    /// expect_lint: avoid_late_keyword
    late final Subscription<String> subscription1;

    /// ignored_types: Subscription<ConcreteTypeWithNoGenerics>
    late final Subscription<ConcreteTypeWithNoGenerics> subscription2;

    /// ignored_types: Subscription<List<String>>
    late final Subscription<List<String>> subscription3;
  }
}
