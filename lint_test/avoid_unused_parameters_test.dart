// ignore_for_file: prefer_const_declarations
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_element

import 'package:flutter/material.dart';

/// Check the `avoid-unused-parameters` rule

// expect_lint: avoid-unused-parameters
void fun(String s) {
  return;
}

class TestClass {
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

class Foo {
  final int a;
  final int? b;

  Foo._(this.a, this.b);

  Foo.name(this.a, this.b);

  Foo.coolName({required this.a, required this.b});

  // expect_lint: avoid-unused-parameters
  Foo.another({required int c})
      : a = 1,
        b = 0;

  // expect_lint: avoid-unused-parameters
  factory Foo.aOnly(int a) {
    return Foo._(1, null);
  }
}

class Bar extends Foo {
  Bar.name(super.a, super.b) : super.name();
}

class TestWidget extends StatelessWidget {
  const TestWidget({
    super.key,
    // expect_lint: avoid-unused-parameters
    int a = 1,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
