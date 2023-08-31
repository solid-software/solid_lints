// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unnecessary_type_check
// ignore_for_file: unused_local_variable

/// Check the `avoid-unnecessary-type-assertions` rule

void fun() {
  final testList = <double>[1.0, 2.0, 3.0];
  // expect_lint: avoid-unnecessary-type-assertions
  final result = testList is List<double>;

  // expect_lint: avoid-unnecessary-type-assertions
  testList.whereType<double>();

  final dynamicList = <dynamic>[1.0, 2.0];
  dynamicList.whereType<double>();

  // just any method, except `whereType`
  testList.add(4.0);

  // expect_lint: avoid-unnecessary-type-assertions
  [1.0, 2.0].whereType<double?>();

  final double d = 2.0;
  // expect_lint: avoid-unnecessary-type-assertions
  final casted = d is double;

  final double? nullableD = 2.0;
  // casting `Type? is Type` is allowed
  final castedD = nullableD is double;
}
