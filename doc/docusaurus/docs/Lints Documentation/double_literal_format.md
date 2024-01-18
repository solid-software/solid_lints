A `double_literal_format` rule which
 checks that double literals should begin with 0. instead of just .,
 and should not end with a trailing 0.
 ```dart
 BAD:
 var a = 05.23, b = .16e+5, c = -0.250, d = -0.400e-5;
 GOOD:
 var a = 5.23, b = 0.16e+5, c = -0.25, d = -0.4e-5;
 ```
