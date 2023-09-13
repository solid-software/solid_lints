// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unused_local_variable

/// Check the `avoid-unrelated-type-assertions` rule
class Foo {}

class Bar {}

class ChildFoo extends Foo {}

void fun() {
  final testString = '';
  final testList = [1, 2, 3];
  final testMap = {'A': 'B'};
  final Foo foo = Foo();
  final childFoo = ChildFoo();

  // expect_lint: avoid-unrelated-type-assertions
  final result = testString is int;

  // expect_lint: avoid-unrelated-type-assertions
  final result2 = testList is List<String>;

  // expect_lint: avoid-unrelated-type-assertions
  final result3 = foo is Bar;

  // expect_lint: avoid-unrelated-type-assertions
  final result4 = childFoo is Bar;

  // expect_lint: avoid-unrelated-type-assertions
  final result5 = testMap['A'] is double;
}
