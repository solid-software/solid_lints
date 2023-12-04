// ignore_for_file: unused_local_variable

import 'dart:collection';

void testingBannedCodeLint() {
  // expect_lint: banned_external_code
  final bannedCodeUsage = BannedCodeUsage();
  // expect_lint: banned_external_code
  BannedCodeUsage.test2();
  // expect_lint: banned_external_code
  final res = BannedCodeUsage.test2();

  // expect_lint: banned_external_code
  bannedCodeUsage.test();

  // expect_lint: banned_external_code
  final bannedCodeUsage2 = BannedCodeUsage.test3();
  // expect_lint: banned_external_code
  BannedCodeUsage.test3().test();
  // expect_lint: banned_external_code
  bannedCodeUsage2.test();
  test2;
  // expect_lint: banned_external_code
  bannedCodeUsage2.test4;
  test();

  // expect_lint: banned_external_code
  final unmodifiable = UnmodifiableListView([1, 2, 3]);

  // expect_lint: banned_external_code
  final first = unmodifiable.first;
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
    // expect_lint: banned_external_code
    return BannedCodeUsage();
  }
}
