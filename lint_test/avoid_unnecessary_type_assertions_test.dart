// ignore_for_file: prefer_const_declarations, prefer_match_file_name, cyclomatic_complexity, unused_element
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unnecessary_type_check
// ignore_for_file: unused_local_variable

/// Check the `avoid_unnecessary_type_assertions` rule

void fun() {
  final testList = [1.0, 2.0, 3.0];
  // expect_lint: avoid_unnecessary_type_assertions
  final result = testList is List<double>;

  // expect_lint: avoid_unnecessary_type_assertions
  final negativeResult = testList is! List<double>;

  // to check quick-fix => testList.length
  // expect_lint: avoid_unnecessary_type_assertions
  testList.whereType<double>().length;

  final dynamicList = <dynamic>[1.0, 2.0];
  dynamicList.whereType<double>();

  // expect_lint: avoid_unnecessary_type_assertions
  [1.0, 2.0].whereType<double?>();

  final double d = 2.0;
  // expect_lint: avoid_unnecessary_type_assertions
  final casted = d is double;

  // expect_lint: avoid_unnecessary_type_assertions
  final negativeCasted = d is! double;

  final double? nullableD = 2.0;
  // casting `Type? is Type` is allowed
  final castedD = nullableD is double;
}

class _A {}

class _B extends _A {}

class _C extends _A {}

void noLint() {
  final _A a = _B();
  if (a is! _C) return;
}
