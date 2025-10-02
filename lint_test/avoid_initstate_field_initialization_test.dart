// ignore_for_file: unused_local_variable, prefer_match_file_name, avoid_late_keyword, member_ordering

import 'package:flutter/widgets.dart';

/// Widget to test avoid_initstate_field_initialization rule.
class TestWidget extends StatefulWidget {
  static const int xConst = 0;
  //ignore: avoid_global_state
  static int xStaticVariable = 0;
  final int xFinal = 0;
  @override
  State<TestWidget> createState() => _TestWidgetStateBad();
}

class _TestWidgetStateBad extends State<TestWidget> {
  late final int? a;
  late final int? b;

  void initState() {
    super.initState();
    //expect_lint: avoid_initstate_field_initialization
    a = widget.xFinal;
    //expect_lint: avoid_initstate_field_initialization
    b = (widget.xFinal + TestWidget.xConst) * 1;
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

// ignore: unused_element
class _TestWidgetStateGood extends State<TestWidget> {
  late final a = widget.xFinal;
  late final int? b;
  late final int? c;
  late final int? d;
  late final int? e;
  late final int? f;
  late final g = widget.xFinal + TestWidget.xConst;
  late final int? h;
  int? k;

  void initState() {
    super.initState();

    //init from local variable
    final bLocal = 1;
    b = bLocal;

    //init from external mutable
    c = TestWidget.xStaticVariable;

    //init from method result
    d = _evaluateSomething();

    //init from expression with variable
    e = widget.xFinal + TestWidget.xStaticVariable;

    //init more than once by arbitrary logic
    f = widget.xFinal;
    if (widget.xFinal <= 0) {
      f = TestWidget.xConst;
    }

    //init conditionally (possible null value)
    if (bLocal <= TestWidget.xConst) {
      h = widget.xFinal;
    }

    //init variable, not final
    k = widget.xFinal;

    //init local variable
    int localInit;
    localInit = 0;
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  int _evaluateSomething() => 1;
}
