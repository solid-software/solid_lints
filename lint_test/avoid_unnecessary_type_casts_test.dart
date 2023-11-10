// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unnecessary_cast
// ignore_for_file: unused_local_variable

/// Check the `avoid_unnecessary_type_casts` rule

void fun() {
  final testList = [1.0, 2.0, 3.0];

  // to check quick-fix => testList
  // expect_lint: avoid_unnecessary_type_casts
  final result = testList as List<double>;

  final double? nullableD = 2.0;
  // casting `Type? is Type` is allowed
  final castedD = nullableD as double;

  final testMap = {'A': 'B'};

  // expect_lint: avoid_unnecessary_type_casts
  final castedMapValue = testMap['A'] as String?;

  // casting `Type? is Type` is allowed
  final castedNotNullMapValue = testMap['A'] as String;

  final testString = 'String';
  // expect_lint: avoid_unnecessary_type_casts
  _testFun(testString as String);
}

void _testFun(String a) {
  // expect_lint: avoid_unnecessary_type_casts
  final result = (a as String).length;
}
