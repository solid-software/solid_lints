// ignore_for_file: prefer_const_declarations, prefer_match_file_name, prefer_early_return
// ignore_for_file: unused_local_variable
// ignore_for_file: cyclomatic_complexity
// ignore_for_file: avoid_unused_parameters

/// Check the `no_empty_block` rule

// expect_lint: no_empty_block
void fun() {}

void anotherFun() {
  if (true) {
    if (true) {
      // expect_lint: no_empty_block
      if (true) {}
    }
  }
}

// to-do comments are allowed
void toDoStuff() {
  // TODO: Implement doStuff function
}

void catchStuff() {
  // expect_lint: no_empty_block
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
  // expect_lint: no_empty_block
  nestedFun(() {});
}

class A {
  // expect_lint: no_empty_block
  void method() {}

  void toDoMethod() {
    // TODO: implement toDoMethod
  }
}

// no lint
void excludeMethod() {}

class Exclude {
  // no lint
  void excludeMethod() {}
}

// no lint
void emptyMethodWithComments() {
  // comment explaining why this block is empty
}

void anotherExample() {
  // no lint
  nestedFun(() {
    // explain why this block is empty
  });
}
