// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unnecessary_cast
// ignore_for_file: unused_local_variable

/// Check the `avoid-unnecessary-type-casts` rule

void fun() {
  final testList = [1.0, 2.0, 3.0];

  // to check quick-fix => testList
  // expect_lint: avoid-unnecessary-type-casts
  final result = testList as List<double>;

  final double? nullableD = 2.0;
  // casting `Type? is Type` is allowed
  final castedD = nullableD as double;
}
