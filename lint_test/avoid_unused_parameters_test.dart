// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_element

/// Check the `avoid-unused-parameters` rule

// expect_lint: avoid-unused-parameters
void fun(String s) {
  return;
}

class TestClass {
  final int b;

  TestClass(this.b);

  // expect_lint: avoid-unused-parameters
  static void staticMethod(int a) {}

  // expect_lint: avoid-unused-parameters
  void method(String s) {
    return;
  }

  void methodWithUnderscores(int _) {}
}

class TestClass2 {
  void method(String _) {
    return;
  }
}

class SomeOtherClass {
  // expect_lint: avoid-unused-parameters
  void method(String s) {
    return;
  }
}

class SomeAnotherClass extends SomeOtherClass {
  @override
  void method(String s) {}
}

void someOtherFunction(String s) {
  print(s);
  return;
}

class SomeOtherAnotherClass {
  void method(String s) {
    print(s);
    return;
  }

  // expect_lint: avoid-unused-parameters
  void anonymousCallback(Function(int a) cb) {}
}

// expect_lint: avoid-unused-parameters
void closure(int a) {
  void internal(int a) {
    print(a);
  }
}

typedef MaxFun = int Function(int a, int b);

// Allowed same way as override
final MaxFun maxFunInstance = (int a, int b) => 1;
