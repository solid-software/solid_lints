class BannedCodeUsage {
  BannedCodeUsage();
  void test() {
    print('Hello World');
  }

  factory BannedCodeUsage.testFactory() {
    return BannedCodeUsage();
  }
}
