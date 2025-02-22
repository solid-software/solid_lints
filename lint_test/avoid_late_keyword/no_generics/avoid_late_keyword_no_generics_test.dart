// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

class Subscription<T> {}

class ConcreteTypeWithNoGenerics {}

class NotAllowed {}

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
/// allow_initialized option disabled
class AvoidLateKeyword {
  /// expect_lint: avoid_late_keyword
  late final NotAllowed na1;

  /// ignored_types: Subscription
  late final Subscription subscription1;

  /// ignored_types: Subscription
  late final Subscription<ConcreteTypeWithNoGenerics> subscription2;

  /// ignored_types: Subscription
  late final Subscription<List<int>> subscription3;

  /// ignored_types: Subscription
  late final Subscription<List<List<int>>> subscription4;

  /// ignored_types: Subscription
  late final Subscription<Map<dynamic, String>> subscription5;

  void test() {
    /// expect_lint: avoid_late_keyword
    late final NotAllowed na1;

    /// ignored_types: Subscription
    late final Subscription subscription1;

    /// ignored_types: Subscription
    late final Subscription<ConcreteTypeWithNoGenerics> subscription2;

    /// ignored_types: Subscription
    late final Subscription<List<int>> subscription3;

    /// ignored_types: Subscription
    late final Subscription<List<List<int>>> subscription4;

    /// ignored_types: Subscription
    late final Subscription<Map<dynamic, String>> subscription5;
  }
}
