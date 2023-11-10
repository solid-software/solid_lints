// ignore_for_file: unused_local_variable
// ignore_for_file: cyclomatic_complexity
// ignore_for_file: no_magic_number
// ignore_for_file: prefer_conditional_expressions

/// Check the `no_equal_then_else` rule
void fun() {
  final _valueA = 1;
  final _valueB = 2;

  int _result = 0;

  // expect_lint: no_equal_then_else
  if (_valueA == 1) {
    _result = _valueA;
  } else {
    _result = _valueA;
  }

  if (_valueA == 1) {
    _result = _valueA;
  } else {
    _result = _valueB;
  }

  // expect_lint: no_equal_then_else
  _result = _valueA == 2 ? _valueA : _valueA;

  _result = _valueA == 2 ? _valueA : _valueB;
}
