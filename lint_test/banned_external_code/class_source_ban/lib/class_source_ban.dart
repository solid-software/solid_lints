import 'dart:collection';

void testingBannedCodeLint() {
  // expect_lint: banned_external_code
  final bannedCodeUsage = BannedCodeUsage();
  // expect_lint: banned_external_code
  BannedCodeUsage.test2();
  // expect_lint: banned_external_code
  final res = BannedCodeUsage.test2();
  print(res);
  // expect_lint: banned_external_code
  bannedCodeUsage.test();

  // expect_lint: banned_external_code
  final bannedCodeUsage2 = BannedCodeUsage.test3();
  // expect_lint: banned_external_code
  BannedCodeUsage.test3().test();
  // expect_lint: banned_external_code
  bannedCodeUsage2.test();
  print(test2);
  // expect_lint: banned_external_code
  print(bannedCodeUsage2.test4);
  test();

  // expect_lint: banned_external_code
  final unmodifiable = UnmodifiableListView([1, 2, 3]);

  final first = unmodifiable.first;
  print(first);
}

const test2 = 'Hello World';

void test() {
  print('Hello World');
}

class BannedCodeUsage {
  BannedCodeUsage();
  static String test2() {
    print('Hello World');
    return 'Hello World';
  }

  final String test4 = 'Hello World';

  void test() {
    print('Hello World');
  }

  factory BannedCodeUsage.test3() {
    // expect_lint: banned_external_code
    return BannedCodeUsage();
  }
}
