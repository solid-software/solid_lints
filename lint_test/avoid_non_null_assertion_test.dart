// ignore_for_file: avoid_global_state, prefer_match_file_name
// ignore_for_file: member_ordering

/// Check "bang" operator fail
///
/// `avoid_non_null_assertion`
class AvoidNonNullAssertion {
  AvoidNonNullAssertion? object;
  int? number;

  void test() {
    // expect_lint: avoid_non_null_assertion
    number!;

    // expect_lint: avoid_non_null_assertion
    object!.number!;

    // expect_lint: avoid_non_null_assertion
    object!.test();

    // No lint on maps
    final map = {'key': 'value'};
    map['key']!;
  }
}
