/// Check number of parameters fail
///
/// `number_of_parameters: max_parameters`
/// expect_lint: number_of_parameters
String numberOfParameters(String a, String b, String c) {
  return a + b + c;
}

void excludeFunction(int a, int, b, int c) {}

class ExcludeClass {
  // expect_lint: number_of_parameters
  void foo(int a, int b, int c) {}

  void excludeMethod(int a, int b, int c) {}
}
