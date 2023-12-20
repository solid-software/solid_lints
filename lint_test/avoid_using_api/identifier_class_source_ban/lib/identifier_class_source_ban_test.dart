// ignore_for_file: unused_local_variable

import 'dart:collection';

void testingBannedCodeLint() async {
  final bannedCodeUsage = BannedCodeUsage();
  // expect_lint: avoid_using_api
  BannedCodeUsage.test2();
  // expect_lint: avoid_using_api
  final res = BannedCodeUsage.test2();
  // expect_lint: avoid_using_api
  bannedCodeUsage.test();

  // expect_lint: avoid_using_api
  final bannedCodeUsage2 = BannedCodeUsage.test3();
  // expect_lint: avoid_using_api
  BannedCodeUsage.test3().test();
  // expect_lint: avoid_using_api
  bannedCodeUsage2.test();
  test2;
  // expect_lint: avoid_using_api
  bannedCodeUsage2.test4;
  test();

  // expect_lint: avoid_using_api
  final unmodifiable = UnmodifiableListView([1, 2, 3]);

  // expect_lint: avoid_using_api
  final first = unmodifiable.first;

  // expect_lint: avoid_using_api
  Future.wait([Future.value(1), Future.value(2)]);

  await (Future.value(1), Future.value(2)).wait;
}

const test2 = 'Hello World';

void test() {}

class BannedCodeUsage {
  BannedCodeUsage();
  static String test2() {
    return 'Hello World';
  }

  final String test4 = 'Hello World';

  void test() {}

  factory BannedCodeUsage.test3() {
    return BannedCodeUsage();
  }
}
