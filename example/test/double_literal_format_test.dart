// ignore_for_file: avoid_global_state
// ignore_for_file: type_annotate_public_apis
// ignore_for_file: unused_local_variable

/// Check the `double-literal-format` rule

// expect_lint: double-literal-format
var badA = 05.23;
var goodA = 5.23;
var stringA = '05.23';

var intA = 0;

// expect_lint: double-literal-format
double badB = -01.2;
double goodB = -1.2;

// expect_lint: double-literal-format
double badC = -001.2;

// expect_lint: double-literal-format
double badExpr = 5.23 + 05.23;

double goodExpr = 5.23 + 5.23;

class DoubleLiteralFormatTest {
  // expect_lint: double-literal-format
  var badA = .16e+5;
  var goodA = 0.16e+5;

  void someMethod() {
    // expect_lint: double-literal-format
    const badA = -0.250;
    const goodA = -0.25;
    // expect_lint: double-literal-format
    const badB = 0.160e+5;
  }
}
