// ignore_for_file: prefer_const_declarations, unused_local_variable

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
class AvoidLateKeyword {
  /// expect_lint: avoid_late_keyword
  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late String field2;

  void test() {
    /// expect_lint: avoid_late_keyword
    late final field3 = 'string';

    /// expect_lint: avoid_late_keyword
    late String field4;
  }
}
