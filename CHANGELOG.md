## 0.1.0

- **BREAKING CHANGE**:
  - Drop support for Dart 2 while preparing for `custom_lint` support
- Add support for `cyclomatic_complexity_metric` via `custom_lint`

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
