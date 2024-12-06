// ignore_for_file: dead_code, cyclomatic_complexity, no_equal_then_else, prefer_match_file_name, consider_making_a_member_private

// ignore: no_empty_block
void _doSomething() {}

void oneIf() {
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }
}

int oneIfWithReturnValue() {
  //no lint
  if (true) {
    _doSomething();
  }

  return 1;
}

void oneIfWithReturn() {
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }

  return;
}

void nestedIf2() {
  //expect_lint: prefer_early_return
  if (true) {
    if (true) {
      _doSomething();
    }
  }
}

int nestedIf2WithReturnValue() {
  //no lint
  if (true) {
    if (true) {
      _doSomething();
    }
  }

  return 1;
}

void nestedIf3() {
  //expect_lint: prefer_early_return
  if (true) {
    if (true) {
      if (true) {
        _doSomething();
      }
    }
  }
}

void oneNestedIf2WithReturn() {
  //expect_lint: prefer_early_return
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
  //expect_lint: prefer_early_return
  if (true) {
    if (true) {
      _doSomething();
    } else {
      _doSomething();
    }
  }
}

void threeIf() {
  //expect_lint: prefer_early_return
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
  //expect_lint: prefer_early_return
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
  //expect_lint: prefer_early_return
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

void twoSeqentialIf() {
  if (false) return;
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }
}

void twoSeqentialIfReturn() {
  //no lint
  if (false) return;
  if (true) return;

  return;
}

void twoSeqentialIfReturn2() {
  //no lint
  if (false) return;
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }

  return;
}

void twoSeqentialIfSomething() {
  //no lint
  if (false) return;
  //no lint
  if (true) {
    _doSomething();
  }

  _doSomething();
}

void twoSeqentialIfSomething2() {
  //no lint
  if (true) {
    _doSomething();
  }
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }
}

void threeSeqentialIfReturn() {
  //no lint
  if (false) return;
  if (true) return;
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }

  return;
}

void threeSeqentialIfReturn2() {
  //no lint
  if (false) return;
  //no lint
  if (true) {
    _doSomething();
  }
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }
}

void oneIfWithThrowWithReturn() {
  //no lint
  if (true) {
    throw '';
  }

  return;
}

void oneIfElseWithThrowReturn() {
  //no lint
  if (true) {
    _doSomething();
  } else {
    throw '';
  }
}

void twoSeqentialIfWithThrow() {
  if (false) throw '';
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }
}

void twoSeqentialIfWithThrowReturn2() {
  //no lint
  if (false) throw '';
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }

  return;
}

void threeSeqentialIfWithThrowReturn() {
  //no lint
  if (false) throw '';
  if (true) throw '';
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }

  return;
}

void threeSeqentialIfWithThrowReturn2() {
  //no lint
  if (false) throw '';
  //no lint
  if (true) {
    _doSomething();
  }
  //expect_lint: prefer_early_return
  if (true) {
    _doSomething();
  }
}
