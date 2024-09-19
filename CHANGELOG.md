## 0.2.3

- Replace deprecated whereNotNull()

## 0.2.2

- Remove LintCode from documentation to improve scores and make it clearer

## 0.2.1

- Fix LintCode issue

## 0.2.0

- Added `avoid_final_with_getter` rule
- Improve `avoid_late_keyword` - `ignored_types` to support ignoring subtype of the node type (https://github.com/solid-software/solid_lints/issues/157)
- Abstract methods should be omitted by `proper_super_calls` (https://github.com/solid-software/solid_lints/issues/159)
- Add a rule prefer_guard_clause for reversing nested if statements (https://github.com/solid-software/solid_lints/issues/91)
- add exclude params support to avoid_returning_widgets rule (https://github.com/solid-software/solid_lints/issues/131)
- add quick fix to avoid_final_with_getter (https://github.com/solid-software/solid_lints/pull/164)
- Renamed `avoid_debug_print` to `avoid_debug_print_in_release`
- The `avoid_debug_print_in_release` no longer reports a warning if the `debugPrint` call is wrapped in a `!kReleaseMode` check.
- Update custom_lints to work with newer Flutter

## 0.1.5

- Added `avoid_debug_print` rule
- Fixed an issue with no_magic_number lint
- Fixed `avoid_unused_parameters` to report positional parameters from typedef if their name are not underscores.
- Improvement for `avoid_returning_widget` lint:
  - ignores methods that override ones that return widget (build() for example)
  - no longer allows returning widgets from methods/functions named build
- Fixed unexpected avoid_unnecessary_type_assertions
- Added `excludeNames` param for `function_lines_of_code` lint
- Improved `avoid_unrelated_type_assertions` to support true and false results
- Set default `cyclomatic_complexity` to 10 (https://github.com/solid-software/solid_lints/issues/146)
  Credits: Arthur Miranda (https://github.com/arthurbcd)

## 0.1.4

- Removed deprecated lints:
  - `always_require_non_null_named_parameters`
  - `avoid_returning_null_for_future`

## 0.1.3

- Bumped custom_lint package to 0.6.0 version

## 0.1.2

- Moved implementation into the `src` folder

## 0.1.1

- Add example readme
- Update dependencies

## 0.1.0

- Remove DCM as a dependency
- Add `custom_lint` and integrate/redo lints from DCM using `custom_lint`:
  - avoid_global_state
  - avoid_late_keyword
  - avoid_non_null_assertion
  - avoid_returning_widgets
  - avoid_unnecessary_setstate
  - avoid_unnecessary_type_assertions
  - avoid_unnecessary_type_casts
  - avoid_unrelated_type_assertions
  - avoid_unused_parameters
  - avoid_using_api
    Credits: getBoolean (https://github.com/getBoolean)
  - cyclomatic_complexity
  - double_literal_format
  - function_lines_of_code
  - member_ordering
  - newline_before_return
  - no_empty_block
  - no_equal_then_else
  - no_magic_number
  - number_of_parameters
  - prefer_conditional_expressions
  - prefer_first
  - prefer_last
  - prefer_match_file_name
  - proper_super_calls

## 0.0.19

- Add rules
  - `avoid_final_parameters`
  - `conditional_uri_does_not_exist`
  - `no_leading_underscores_for_library_prefixes`
  - `no_leading_underscores_for_local_identifiers`
  - `noop_primitive_operations`
  - `prefer_adjacent_string_concatenation`
  - `prefer_foreach`
  - `secure_pubspec_urls`
  - `sized_box_shrink_expand`
  - `unnecessary_breaks`
  - `unnecessary_lambdas`
  - `unnecessary_to_list_in_spreads`
  - `use_raw_strings`
- Bump minimum supported sdk to `3.0.0`

## 0.0.18

- Add rules
  - `use_super_parameters`
  - `always_put_required_named_parameters_first`
  - `avoid_redundant_argument_values`

## 0.0.17

- Lock DCM version as they switch to proprietary license.

## 0.0.16

- Update `dart_code_metrics` dependency to 5.7.3
- Rename deprecated `member-ordering-extended` to `member-ordering`
- Add rule for widgets methods order configuration:
  - initState
  - build
  - didChangeDependencies
  - didUpdateWidget
  - deactivate
  - dispose

## 0.0.15

- Add support for Dart 3

## 0.0.14

- Disabe invariant_booleans as it is deprecated in Flutter 3.7

## 0.0.13

- enable use_colored_box & use_decorated_box + add more comments about specific lints

## 0.0.12

- Update to the latest DCM to make sure that it works with latest flutter.

## 0.0.11

- Disabe do_not_use_environment as we need to for Flutter for web

## 0.0.10

- Update `dart_code_metrics` dependency to 4.10.1
- Ignore `mockito` mocks generated to be alongside source test files

## 0.0.9

- Remove `diagnostic_describe_all_properties` rule
- Disable cyclomatic complexity metric for tests

## 0.0.8

- Exclude generated files

## 0.0.7

- Add more useful DCM rules.

## 0.0.6

- Add a separate anayisis options file for tests

## 0.0.5

- Remove the `sort_constructors_first` rule

## 0.0.4

- Set maximum method length to 200
- Set maximum parameters list length to 7

## 0.0.3

- Configure rules based on Flutter 2.5 (Dart 2.14.4)

## 0.0.2

- Updated readme

## 0.0.1

- Preview
