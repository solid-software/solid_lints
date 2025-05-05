// ignore_for_file: unused_element, unused_field

/// `prefer_match_file_name` rule will be ignored by this enttiy because of
/// exclude_entity:
/// - enum
/// in analysis_options.yaml
enum Ignored { _ }

enum IgnoredAgain { _ }

// expect_lint: prefer_match_file_name
abstract class WrongNamedClass {}

/// Only first public element declaration is checked
class PreferMatchFileNameIgnoreExtensions {}
