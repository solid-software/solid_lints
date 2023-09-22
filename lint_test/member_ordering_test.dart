// ignore_for_file: unused_field, prefer-match-file-name
// ignore_for_file: unused_element
// ignore_for_file: no-empty-block

import 'package:flutter/widgets.dart';

/// Check the `member-ordering` rule

class AlphabeticalClass {
  final b = 1;

  // expect_lint: member-ordering
  final a = 1;
  final c = 1;

  void bStuff() {}

  // expect_lint: member-ordering
  void aStuff() {}

  void cStuff() {}

  void visitStatement() {}

  // expect_lint: member-ordering
  void visitStanford() {}
}

class CorrectOrder {
  final publicField = 1;
  int _privateField = 2;

  CorrectOrder();

  int get privateFieldGetter => _privateField;

  void set privateFieldSetter(int value) {
    _privateField = value;
  }

  void publicDoStuff() {}

  void _privateDoStuff() {}

  void close() {}
}

class WrongOrder {
  void close() {}

  // expect_lint: member-ordering
  void _privateDoStuff() {}

  // expect_lint: member-ordering
  void publicDoStuff() {}

  // expect_lint: member-ordering
  void set privateFieldSetter(int value) {
    _privateField = value;
  }

  // expect_lint: member-ordering
  int get privateFieldGetter => _privateField;

  // expect_lint: member-ordering
  WrongOrder();

  // expect_lint: member-ordering
  int _privateField = 2;

  // expect_lint: member-ordering
  final publicField = 1;
}

class PartiallyWrongOrder {
  final publicField = 1;

  PartiallyWrongOrder();

  // expect_lint: member-ordering
  int _privateField = 2;

  int get privateFieldGetter => _privateField;

  void set privateFieldSetter(int value) {
    _privateField = value;
  }

  void _privateDoStuff() {}

  // expect_lint: member-ordering
  void publicDoStuff() {}

  void close() {}
}

class CorrectWidget extends StatefulWidget {
  @override
  State<CorrectWidget> createState() => _CorrectWidgetState();

  const CorrectWidget({super.key});
}

class _CorrectWidgetState extends State<CorrectWidget> {
  static const constField = 1;
  static final staticField = 1;

  static void staticDoStuff() {}

  final publicField = 1;
  final _privateField = 1;

  void publicDoStuff() {}

  void _privateDoStuff() {}

  _CorrectWidgetState();

  @override
  Widget build(BuildContext context) => throw UnimplementedError();

  @override
  void initState() => super.initState();

  @override
  void didChangeDependencies() => super.didChangeDependencies();

  @override
  void didUpdateWidget(covariant CorrectWidget oldWidget) =>
      super.didUpdateWidget(oldWidget);

  @override
  void dispose() => super.dispose();
}

class WrongWidget extends StatefulWidget {
  const WrongWidget({super.key});

  // expect_lint: member-ordering
  @override
  State<WrongWidget> createState() => _WrongWidgetState();
}

class _WrongWidgetState extends State<WrongWidget> {
  @override
  void dispose() => super.dispose();

  // expect_lint: member-ordering
  @override
  void didUpdateWidget(covariant WrongWidget oldWidget) =>
      super.didUpdateWidget(oldWidget);

  // expect_lint: member-ordering
  @override
  void didChangeDependencies() => super.didChangeDependencies();

  // expect_lint: member-ordering
  @override
  void initState() => super.initState();

  // expect_lint: member-ordering
  @override
  Widget build(BuildContext context) => throw UnimplementedError();

  // expect_lint: member-ordering
  _WrongWidgetState();

  // expect_lint: member-ordering
  void _privateDoStuff() {}

  // expect_lint: member-ordering
  void publicDoStuff() {}

  // expect_lint: member-ordering
  final _privateField = 1;

  // expect_lint: member-ordering
  final publicField = 1;

  // expect_lint: member-ordering
  static void staticDoStuff() {}

  // expect_lint: member-ordering
  static final staticField = 1;

  // expect_lint: member-ordering
  static const constField = 1;
}

class PartiallyCorrectWidget extends StatefulWidget {
  @override
  State<PartiallyCorrectWidget> createState() => _PartiallyCorrectWidgetState();

  const PartiallyCorrectWidget({super.key});
}

class _PartiallyCorrectWidgetState extends State<PartiallyCorrectWidget> {
  static final staticField = 1;

  // expect_lint: member-ordering
  static const constField = 1;

  static void staticDoStuff() {}

  final _privateField = 1;

  // expect_lint: member-ordering
  final publicField = 1;

  void publicDoStuff() {}

  void _privateDoStuff() {}

  _PartiallyCorrectWidgetState();

  @override
  Widget build(BuildContext context) => throw UnimplementedError();

  @override
  void didChangeDependencies() => super.didChangeDependencies();

  // expect_lint: member-ordering
  @override
  void initState() => super.initState();

  @override
  void didUpdateWidget(covariant PartiallyCorrectWidget oldWidget) =>
      super.didUpdateWidget(oldWidget);

  @override
  void dispose() => super.dispose();
}
