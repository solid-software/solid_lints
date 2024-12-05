// ignore_for_file: prefer_const_declarations, prefer_match_file_name, avoid_global_state
// ignore_for_file: unnecessary_nullable_for_final_variable_declarations
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_element
// ignore_for_file: newline_before_return
// ignore_for_file: no_empty_block
// ignore_for_file: member_ordering

import 'package:flutter/material.dart';

/// Check the `avoid_unused_parameters` rule
///
void testNamed() {
  SomeAnotherClass(
    func: ({required text}) {},
  );
}

typedef MaxFun = int Function(int a, int b);

typedef Named = String Function({required String text});

typedef ReqNamed = void Function({required String text});

// expect_lint: avoid_unused_parameters
final MaxFun bad = (int a, int b) => 1;

final MaxFun good = (int a, _) => a;

final MaxFun ok = (int _, int __) => 1;

final MaxFun goodMax = (int a, int b) {
  return a + b;
};

final Named _named = ({required text}) {
  return '';
};

void ch({String text = ''}) {}

final Named _named2 = ({required text}) {
  return text;
};

final Named _named3 = ({required text}) => '';

final Named _named4 = ({required text}) => text;

// expect_lint: avoid_unused_parameters
final optional = (int a, [int b = 0]) {
  return a;
};

// expect_lint: avoid_unused_parameters
final named = (int a, {required int b, int c = 0}) {
  return c;
};

// good
var k = (String g) {
  return g;
};

// expect_lint: avoid_unused_parameters
var c = (String g) {
  return '0';
};

// expect_lint: avoid_unused_parameters
final MaxFun tetsFun = (int a, int b) {
  return 4;
};

// expect_lint: avoid_unused_parameters
void fun(String s) {
  return;
}

// expect_lint: avoid_unused_parameters
void fun2(String s) {
  return;
}

class TestClass {
  // expect_lint: avoid_unused_parameters
  static void staticMethod(int a) {}

  // expect_lint: avoid_unused_parameters
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
  // expect_lint: avoid_unused_parameters
  final MaxFun maxFunLint = (int a, int b) => 1;

  // Good
  final MaxFun good = (int a, int b) {
    return a * b;
  };

  // expect_lint: avoid_unused_parameters
  void method(String s) {
    return;
  }
}

class SomeAnotherClass extends SomeOtherClass {
  final ReqNamed func;

  SomeAnotherClass({
    required this.func,
  });

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

  // expect_lint: avoid_unused_parameters
  void anonymousCallback(Function(int a) cb) {}
}

// expect_lint: avoid_unused_parameters
void closure(int a) {
  void internal(int a) {
    print(a);
  }
}

// expect_lint: avoid_unused_parameters
final MaxFun maxFunInstance = (int a, int b) => 1;

final MaxFun m = (_, __) => 1;

class Foo {
  final int a;
  final int? b;

  Foo._(this.a, this.b);

  Foo.name(this.a, this.b);

  Foo.coolName({required this.a, required this.b});

  // expect_lint: avoid_unused_parameters
  Foo.another({required int c})
      : a = 1,
        b = 0;

  // expect_lint: avoid_unused_parameters
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
    // expect_lint: avoid_unused_parameters
    int a = 1,
    // expect_lint: avoid_unused_parameters
    String k = '',
  });

  // expect_lint: avoid_unused_parameters
  factory TestWidget.a([int b = 0]) {
    return TestWidget(k: '');
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class UsingConstructorParameterInInitializer {
  final int _value;

  UsingConstructorParameterInInitializer(int value) : _value = value;

  void printValue() {
    print(_value);
  }
}

// no lint
void excludeMethod(String s) {
  return;
}

class Exclude {
  // no lint
  void excludeMethod(String s) {
    return;
  }

// expect_lint: avoid_unused_parameters
  void excludeMethod2(String s) {
    return;
  }
}
