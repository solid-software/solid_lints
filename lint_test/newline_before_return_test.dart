// ignore_for_file: unused_local_variable, prefer_match_file_name
// ignore_for_file: member_ordering
// ignore_for_file: avoid_unused_parameters

/// Check the `newline_before_return` rule
class Foo {
  int method() {
    final a = 0;
    // expect_lint: newline_before_return
    return 1;
  }

  void anotherMethod() {
    final a = 1;
    // expect_lint: newline_before_return
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
    // expect_lint: newline_before_return
    return;
  });
  // expect_lint: newline_before_return
  return;
}
