// ignore_for_file: avoid_global_state

/// Check `double-literal-format` rule

// expect_lint: double-literal-format
var a = 05.23;

class DoubleLiteralFormatTest {
  // expect_lint: double-literal-format
  var b = .16e+5;

  void someMethod() {
    // expect_lint: double-literal-format
    const c = -0.250;
  }
}
