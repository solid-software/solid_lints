// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unused_local_variable

/// Check the `avoid-unused-parameters` rule

// expect_lint: avoid-unused-parameters
void fun(String s) {
  return;
}

class TestClass {
  // expect_lint: avoid-unused-parameters
  void method(String s) {
    return;
  }
}

class TestClass2 {
  void method(String _) {
    return;
  }
}

class SomeAnotherClass extends TestClass {
  @override
  void method(String s) {}
}

class SomeOtherClass {
  void method() {
    return;
  }
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
}
