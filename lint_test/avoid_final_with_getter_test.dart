// ignore_for_file: type_annotate_public_apis, prefer_match_file_name, unused_local_variable

/// Check final private field with getter fail
/// `avoid_final_with_getter`

class Fail {
  final int _myField = 0;

  // expect_lint: avoid_final_with_getter
  int get myField => _myField;
}

class FailOtherName {
  final int _myField = 0;

  // expect_lint: avoid_final_with_getter
  int get myFieldInt => _myField;
}

class FailStatic {
  static final int _myField = 0;

  // expect_lint: avoid_final_with_getter
  static int get myField => _myField;
}

class Skip {
  final int _myField = 0;

  int get myField => _myField + 1; // it is not a getter for the field
}

class Good {
  final int myField = 0;
}
