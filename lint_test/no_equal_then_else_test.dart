// ignore_for_file: unused_local_variable
// ignore_for_file: cyclomatic_complexity
// ignore_for_file: no-magic-number

/// Check the `no-equal-then-else` rule
void fun() {
  final _valueA = 1;
  final _valueB = 2;

  int _result = 0;

  // expect_lint: no-equal-then-else
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

  // expect_lint: no-equal-then-else
  _result = _valueA == 2 ? _valueA : _valueA;

  _result = _valueA == 2 ? _valueA : _valueB;
}
