// ignore_for_file: prefer_const_declarations, prefer_match_file_name, unused_element
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unused_local_variable

/// Check the `avoid_unrelated_type_assertions` rule
class Foo {}

class Bar {}

class ChildFoo extends Foo {}

void fun() {
  final testString = '';
  final testList = [1, 2, 3];
  final testMap = {'A': 'B'};
  final Foo foo = Foo();
  final childFoo = ChildFoo();

  // expect_lint: avoid_unrelated_type_assertions
  final result = testString is int;

  // expect_lint: avoid_unrelated_type_assertions
  final result2 = testList is List<String>;

  // expect_lint: avoid_unrelated_type_assertions
  final result3 = foo is Bar;

  // expect_lint: avoid_unrelated_type_assertions
  final result4 = childFoo is Bar;

  // expect_lint: avoid_unrelated_type_assertions
  final result5 = testMap['A'] is double;
}

class _A {}

class _B extends _A {}

class _C {}

void lint() {
  final _A a = _B();
  // Always true
  // expect_lint: avoid_unrelated_type_assertions
  if (a is! _C) return;
  // Always false
  // expect_lint: avoid_unrelated_type_assertions
  if (a is _C) return;
}
