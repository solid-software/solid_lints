// ignore_for_file: avoid_global_state

/// Check unnecessary setstate fail
/// `avoid_unnecessary_setstate`
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String myString = '';
  bool condition = true;

  @override
  void initState() {
    super.initState();

    // expect_lint: avoid_unnecessary_setstate
    setState(() {
      myString = "Hello";
    });

    if (condition) {
      // expect_lint: avoid_unnecessary_setstate
      setState(() {
        myString = "Hello";
      });
    }

    // expect_lint: avoid_unnecessary_setstate
    myStateUpdateMethod();
  }

  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // expect_lint: avoid_unnecessary_setstate
    setState(() {
      myString = "Hello";
    });
  }

  void myStateUpdateMethod() {
    setState(() {
      myString = "Hello";
    });
  }

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_unnecessary_setstate
    setState(() {
      myString = "Hello";
    });

    if (condition) {
      // expect_lint: avoid_unnecessary_setstate
      setState(() {
        myString = "Hello";
      });
    }

    // expect_lint: avoid_unnecessary_setstate
    myStateUpdateMethod();

    return ElevatedButton(
      onPressed: () => myStateUpdateMethod(),
      onLongPress: () {
        setState(() {
          myString = 'data';
        });
      },
      child: const Text('PRESS'),
    );
  }
}
