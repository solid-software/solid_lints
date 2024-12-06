// ignore_for_file: unused_field, consider_making_a_member_private
// ignore_for_file: unused_element
// ignore_for_file: prefer_match_file_name

/// Check the `member_ordering` rule
/// alphabetical-by-type option enabled

class CorrectAlphabeticalByTypeClass {
  final int a = 1;
  final double e = 1;
}

class WrongAlphabeticalByTypeClass {
  final int e = 1;

  // expect_lint: member_ordering
  final double a = 1;
}

class PartiallyWrongAlphabeticalByTypeClass {
  final int a = 1;
  final String str = 's';

  // expect_lint: member_ordering
  final double e = 1;
}
