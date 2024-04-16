// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

class Subscription<T> {}

class ConcreteTypeWithNoGenerics {}

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
/// allow_initialized option enabled
class AvoidLateKeyword {
  late final Subscription subscription1;

  late final Subscription<ConcreteTypeWithNoGenerics> subscription2;

  late final Subscription<List<int>> subscription3;

  late final Subscription<List<List<int>>> subscription4;

  late final Subscription<Map<dynamic, String>> subscription5;

  void test() {
    late final Subscription subscription1;

    late final Subscription<ConcreteTypeWithNoGenerics> subscription2;

    late final Subscription<List<int>> subscription3;

    late final Subscription<List<List<int>>> subscription4;

    late final Subscription<Map<dynamic, String>> subscription5;
  }
}
