// ignore_for_file: prefer_const_declarations, unused_local_variable, prefer_match_file_name
// ignore_for_file: avoid_global_state

/// Check "late" keyword fail
///
/// `avoid_late_keyword`
class AvoidLateKeyword {
  late final field1 = 'string';

  /// expect_lint: avoid_late_keyword
  late String field2;

  

  void test() {
    late final field3 = 'string';

    /// expect_lint: avoid_late_keyword
    late String field4;
  }
}
