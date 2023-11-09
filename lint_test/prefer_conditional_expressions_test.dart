// ignore_for_file: unused_local_variable
// ignore_for_file: cyclomatic_complexity
// ignore_for_file: no_equal_then_else
// ignore_for_file: dead_code
// ignore_for_file: no_magic_number

/// Check the `prefer_conditional_expressions` rule
void fun() {
  int _result = 0;

  // expect_lint: prefer_conditional_expressions
  if (true) {
    _result = 1;
  } else {
    _result = 2;
  }

  // expect_lint: prefer_conditional_expressions
  if (1 > 0)
    _result = 1;
  else
    _result = 2;

  // expect_lint: prefer_conditional_expressions
  if (1 > 0) {
    _result = 1 > 2 ? 2 : 1;
  } else {
    _result = 0;
  }
}

int someFun() {
  // expect_lint: prefer_conditional_expressions
  if (1 == 1) {
    return 0;
  } else {
    return 1;
  }
}

int anotherFun() {
  // expect_lint: prefer_conditional_expressions
  if (1 > 0)
    return 1;
  else
    return 2;
}
