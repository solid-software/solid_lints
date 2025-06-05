// ignore_for_file: prefer_match_file_name
// ignore_for_file: no_empty_block

class BannedCodeUsage {
  final String test4 = 'Hello World';

  BannedCodeUsage({this.parameter1, this.parameter2});

  String? parameter1;
  String? parameter2;

  factory BannedCodeUsage.test3({String? parameter1, String? parameter2}) {
    return BannedCodeUsage(
      parameter1: parameter1,
      parameter2: parameter2,
    );
  }

  BannedCodeUsage.test5({String? parameter1, String? parameter2});

  void test({String? parameter1, String? parameter2}) {}

  static String test2({String? parameter1, String? parameter2}) {
    return 'Hello World';
  }
}

const test2 = 'Hello World';

void test({String? parameter1}) {}

int banned = 5;

extension BannedExtension on int {
  int banned({String? parameter1, String? parameter2}) => this + 10;

  int get bannedGetter => 10;
}
