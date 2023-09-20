// ignore_for_file: unused_element, unused_field

/// Check the `prefer-match-file-name` rule
class _AnotherPrivateClass {}

// expect_lint: prefer-match-file-name
class WrongClass {}

/// Only first public element declaration is checked
class PreferMatchFileNameWrongTest {}
