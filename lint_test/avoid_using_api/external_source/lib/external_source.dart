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

const test2 = 'Hello World';

void test() {}

int banned = 5;
