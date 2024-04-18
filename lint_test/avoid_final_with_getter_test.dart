// ignore_for_file: type_annotate_public_apis, prefer_match_file_name, unused_local_variable

/// Check final private field with getter fail
/// `avoid_final_with_getter`

class Fail {
  // expect_lint: avoid_final_with_getter
  final int _myField = 0;

  int get myField => _myField;
}

class Skipped {
  final int _myField = 0;

  int get myField => _myField + 1;
}

class Good {
  final int myField = 0;
}
