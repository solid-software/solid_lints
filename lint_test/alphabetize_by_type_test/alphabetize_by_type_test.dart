// ignore_for_file: unused_field
// ignore_for_file: unused_element

/// Check the `member-ordering` rule
/// alphabetical-by-type option enabled

class CorrectAlphabeticalByTypeClass {
  final double e = 1;
  final int a = 1;
}

class WrongAlphabeticalByTypeClass {
  final int a = 1;

  // expect_lint: member-ordering
  final double e = 1;
}

class PartiallyWrongAlphabeticalByTypeClass {
  final int a = 1;
  final String str = 's';

  // expect_lint: member-ordering
  final double e = 1;
}
