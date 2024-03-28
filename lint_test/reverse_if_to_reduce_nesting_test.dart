// ignore_for_file: dead_code, cyclomatic_complexity, no_equal_then_else, prefer_match_file_name

// ignore: no_empty_block
void _doSomething() {}

void oneIf() {
  //no lint
  if (true) {
    _doSomething();
  }
}

void oneIfWithReturn() {
  //no lint
  if (true) {
    _doSomething();
  }

  return;
}

void nestedIf2() {
  //expect_lint: reverse_if_to_reduce_nesting
  if (true) {
    if (true) {
      _doSomething();
    }
  }
}

void nestedIf3() {
  //expect_lint: reverse_if_to_reduce_nesting
  if (true) {
    if (true) {
      if (true) {
        _doSomething();
      }
    }
  }
}

void oneNestedIf2WithReturn() {
  //expect_lint: reverse_if_to_reduce_nesting
  if (true) {
    if (true) {
      if (true) {
        _doSomething();
      }
    }
  }

  return;
}

void oneIfElse() {
  //no lint
  if (true) {
    _doSomething();
  } else {
    _doSomething();
  }
}

void oneIfElseReturn() {
  //no lint
  if (true) {
    _doSomething();
  } else {
    return;
  }
}

void twoIfElse() {
  //no lint
  if (true) {
    if (true) {
      _doSomething();
    }
  } else {
    _doSomething();
  }
}

void twoIfElseInner() {
  //expect_lint: reverse_if_to_reduce_nesting
  if (true) {
    if (true) {
      _doSomething();
    } else {
      _doSomething();
    }
  }
}

void threeIf() {
  //expect_lint: reverse_if_to_reduce_nesting
  if (true) {
    if (true) {
      if (true) {
        _doSomething();
      }
    }
  }
}

void threeIfElse1() {
  //no lint
  if (true) {
    if (true) {
      if (true) {
        _doSomething();
      }
    }
  } else {
    _doSomething();
  }
}

void threeIfElse2() {
  //expect_lint: reverse_if_to_reduce_nesting
  if (true) {
    if (true) {
      if (true) {
        _doSomething();
      }
    } else {
      _doSomething();
    }
  }
}

void threeIfElse3() {
  //expect_lint: reverse_if_to_reduce_nesting
  if (true) {
    if (true) {
      if (true) {
        _doSomething();
      } else {
        _doSomething();
      }
    }
  }
}
