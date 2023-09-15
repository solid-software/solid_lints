// ignore_for_file: unused_local_variable
// ignore_for_file: member-ordering
// ignore_for_file: avoid-unused-parameters

/// Check the `newline-before-return` rule
class Foo {
  int method() {
    final a = 0;
    // expect_lint: newline-before-return
    return 1;
  }

  void anotherMethod() {
    final a = 1;
    // expect_lint: newline-before-return
    return;
  }

  void bar(void Function()) {
    return;
  }
}

void fun() {
  final foo = Foo();
  foo.bar(() {
    // This comment is ignored and line above is checked to be a newline
    return;
  });
  foo.bar(() {
    final a = 1;
    // expect_lint: newline-before-return
    return;
  });
  // expect_lint: newline-before-return
  return;
}
