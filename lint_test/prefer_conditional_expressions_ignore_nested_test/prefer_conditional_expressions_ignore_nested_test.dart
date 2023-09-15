// ignore_for_file: unused_local_variable
// ignore_for_file: cyclomatic_complexity
// ignore_for_file: no-equal-then-else

/// Check the `prefer-conditional-expressions` rule ignore-nested option
void fun() {
  int _result = 0;

  // Allowed because ignore-nested flag is set tot true
  if (1 > 0) {
    _result = 1 > 2 ? 2 : 1;
  } else {
    _result = 0;
  }
}
