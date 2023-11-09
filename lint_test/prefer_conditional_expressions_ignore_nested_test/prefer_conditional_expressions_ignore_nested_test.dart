// ignore_for_file: unused_local_variable
// ignore_for_file: cyclomatic_complexity
// ignore_for_file: no_equal_then_else

/// Check the `prefer_conditional_expressions` rule ignore_nested option
void fun() {
  int _result = 0;

  // Allowed because ignore_nested flag is enabled
  if (1 > 0) {
    _result = 1 > 2 ? 2 : 1;
  } else {
    _result = 0;
  }
}
