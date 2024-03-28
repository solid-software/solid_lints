// ignore_for_file: dead_code, cyclomatic_complexity, no_equal_then_else

// ignore: no_empty_block
void _doSomething() {}

void onlyIf() {
  if (true) {
    _doSomething();
  }
}

void onlyIfReturn() {
  if (true) {
    _doSomething();

    return;
  }
}

void onlyIfReturnElse() {
  // expect_lint: prefer_guard_close
  if (true) {
    _doSomething();
  } else {
    return;
  }
}

void onlyIfElseReturn() {
  // expect_lint: prefer_guard_close
  if (true) {
    _doSomething();
  } else {
    return;
  }
}

void startWithIf() {
  // no lint
  if (true) {
    _doSomething();
  }
  _doSomething();
}

void startWithIfReturn() {
  // no lint
  if (true) {
    return;
  }
  _doSomething();
}

void startWithElse() {
  // no lint
  if (true) {
    _doSomething();
  } else {
    _doSomething();
  }
  _doSomething();
}

void startWithIfReturnElse() {
  // expect_lint: prefer_guard_close
  if (true) {
    return;
  } else {
    _doSomething();
  }
  _doSomething();
}

void startWithIfElseReturn() {
  // expect_lint: prefer_guard_close
  if (true) {
    _doSomething();
  } else {
    return;
  }
  _doSomething();
}

void startWithElseIf() {
  // no lint
  if (false) {
    _doSomething();
  } else if (true) {
    return;
  } else {
    return;
  }
  _doSomething();
}

void middle() {
  _doSomething();
  //no lint
  if (true) {
    _doSomething();
  }
  _doSomething();
}

void middleIfWithReturn() {
  _doSomething();
  //no lint
  if (true) {
    _doSomething();
  }

  return;
}

void middleIfReturnWithReturn() {
  _doSomething();
  //no lint
  if (true) {
    return;
  }

  return;
}

void endWithIf() {
  _doSomething();
  // expect_lint: prefer_guard_close
  if (true) {
    _doSomething();
  }
}

void endWithIfElse() {
  _doSomething();
  // no lint
  if (true) {
    _doSomething();
  } else {
    _doSomething();
  }
}

void endWithIfReturn() {
  _doSomething();
  // no lint
  if (true) {
    return;
  }
}

void endWithIfReturnElse() {
  _doSomething();
  // expect_lint: prefer_guard_close
  if (true) {
    return;
  } else {
    _doSomething();
  }
}

void endWithIfElseReturn() {
  _doSomething();
  // expect_lint: prefer_guard_close
  if (true) {
    _doSomething();
  } else {
    return;
  }
}

void endWithIfElseIf() {
  _doSomething();
  // no lint
  if (false) {
    _doSomething();
  } else if (true) {
    _doSomething();
  }
}

void endReturnWithIf() {
  _doSomething();
  // expect_lint: prefer_guard_close
  if (true) {
    _doSomething();
  }

  return;
}

void endReturnWithIfReturn() {
  _doSomething();
  // no lint
  if (true) {
    return;
  }
  _doSomething();

  return;
}

void endReturnWithIfElse() {
  _doSomething();
  // no lint
  if (true) {
    _doSomething();
  } else {
    _doSomething();
  }
  _doSomething();

  return;
}

void endReturnWithIfReturnElse() {
  _doSomething();
  // expect_lint: prefer_guard_close
  if (true) {
    return;
  } else {
    _doSomething();
  }
  _doSomething();

  return;
}

void endReturnWithIfElseReturn() {
  _doSomething();
  // expect_lint: prefer_guard_close
  if (true) {
    _doSomething();
  } else {
    return;
  }
  _doSomething();

  return;
}
