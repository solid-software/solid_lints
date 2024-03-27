// ignore_for_file: dead_code, cyclomatic_complexity, no_equal_then_else

// ignore: no_empty_block
void _doSomething() {}

void fun() {
  //no lint
  if (true) {
    _doSomething();
  } else {
    _doSomething();
  }
}

void fun2() {
  // expect_lint: reverse_if_to_avoid_nesting
  if (true) {
    _doSomething();
  }
}

void fun3() {
  // expect_lint: reverse_if_to_avoid_nesting
  if (true) {
    _doSomething();
  }
  _doSomething();
}

void fun4() {
  // no lint
  if (false) {
    return;
  }
  _doSomething();
  _doSomething();
}

void fun5() {
  // expect_lint: reverse_if_to_avoid_nesting
  if (true) {
    // no lint
    if (true) {
      _doSomething();
    } else {
      _doSomething();
    }
  }
}

void fun6() {
  // no lint
  if (false) {
    _doSomething();
  } else if (true) {
    _doSomething();
  } else {
    _doSomething();
  }
}

void fun7() {
  // no lint
  if (false) {
    _doSomething();
  } else if (true) {
    _doSomething();
  }
}

void fun8() {
  //no lint
  if (true) {
    _doSomething();
  }
  _doSomething();
}

void fun9() {
  // expect_lint: reverse_if_to_avoid_nesting
  if (true) {
    _doSomething();
  }
}

void fun10() {
  //no lint
  if (true) return;
}
