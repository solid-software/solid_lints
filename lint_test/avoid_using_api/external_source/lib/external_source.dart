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

int banned = 5;

extension BannedExtension on int {
  int banned() => this + 10;

  int get bannedGetter => 10;
}
