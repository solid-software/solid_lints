// ignore_for_file: unused_element, unused_field

/// Check the `prefer_match_file_name` rule
class _AnotherPrivateClass {}

// expect_lint: prefer_match_file_name
class WrongClass {}

/// Only first public element declaration is checked
class PreferMatchFileNameWrongTest {}
