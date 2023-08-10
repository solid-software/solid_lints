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
