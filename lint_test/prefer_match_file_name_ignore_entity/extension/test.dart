// ignore_for_file: unused_element, unused_field

/// `prefer_match_file_name` rule will be ignored by this extension because of
/// exclude_entity:
/// - extension
/// in analysis_options.yaml
extension Ignored on String {}

extension IgnoredAgain on String {}

// expect_lint: prefer_match_file_name
abstract class WrongNamedClass {}

/// Only first public element declaration is checked
class PreferMatchFileNameIgnoreExtensions {}
