class BannedCodeUsage {
  BannedCodeUsage();
  void test() {}

  factory BannedCodeUsage.testFactory() {
    return BannedCodeUsage();
  }
}
