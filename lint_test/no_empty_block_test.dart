// ignore_for_file: prefer_const_declarations
// ignore_for_file: unused_local_variable
// ignore_for_file: cyclomatic_complexity
// ignore_for_file: avoid-unused-parameters

/// Check the `no-empty-block` rule

// expect_lint: no-empty-block
void fun() {}

void anotherFun() {
  if (true) {
    if (true) {
      // expect_lint: no-empty-block
      if (true) {}
    }
  }
}

// to-do comments are allowed
void toDoStuff() {
  // TODO: Implement doStuff function
}

void catchStuff() {
  // expect_lint: no-empty-block
  try {} catch (e) {}

  try {
    print('do stuff');
    // empty catch block is allowed
  } catch (e) {}
}

void nestedFun(void Function() fun) {
  return;
}

void doStuff() {
  // expect_lint: no-empty-block
  nestedFun(() {});
}

class A {
  // expect_lint: no-empty-block
  void method() {}

  void toDoMethod() {
    // TODO: implement toDoMethod
  }
}
