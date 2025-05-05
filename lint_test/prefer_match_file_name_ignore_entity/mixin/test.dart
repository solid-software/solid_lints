// ignore_for_file: unused_element, unused_field

/// `prefer_match_file_name` rule will be ignored by this entity because of
/// exclude_entity:
/// - mixin
/// in analysis_options.yaml
mixin IgnoredMixin {}

// expect_lint: prefer_match_file_name
abstract class WrongNamedClass {}

/// Only first public element declaration is checked
class PreferMatchFileNameIgnoreExtensions {}
