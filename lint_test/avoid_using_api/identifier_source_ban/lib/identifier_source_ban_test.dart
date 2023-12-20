void testingBannedCodeLint() {
  final bannedCodeUsage = BannedCodeUsage();
  bannedCodeUsage.test();

  // expect_lint: avoid_using_api
  test();
}

void test() {}

class BannedCodeUsage {
  BannedCodeUsage();

  void test() {}
}
