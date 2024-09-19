// ignore_for_file: prefer_match_file_name
// ignore_for_file: no_empty_block

class BannedCodeUsage {
  final String test4 = 'Hello World';

  BannedCodeUsage();

  factory BannedCodeUsage.test3() {
    return BannedCodeUsage();
  }

  void test() {}

  static String test2() {
    return 'Hello World';
  }
}

const test2 = 'Hello World';

void test() {}

// expect_lint: avoid_global_state
int banned = 5;
