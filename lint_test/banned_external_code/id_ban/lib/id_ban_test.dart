void testingBannedCodeLint() {
  final bannedCodeUsage = BannedCodeUsage();
  bannedCodeUsage.test();

  final bannedCodeUsage2 = BannedCodeUsage.test3();
  BannedCodeUsage.test3().test();
  bannedCodeUsage2.test();
  test2;

  // expect_lint: banned_external_code
  test();
}

const test2 = 'Hello World';

void test() {}

class BannedCodeUsage {
  BannedCodeUsage();

  void test() {}

  void useTest() {
    test(); // implicit `this`, no lint expected
  }

  factory BannedCodeUsage.test3() {
    return BannedCodeUsage();
  }
}
