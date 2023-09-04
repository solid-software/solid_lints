// MIT License
//
// Copyright (c) 2020-2021 Dart Code Checker team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:flutter/material.dart';

/// Check unnecessary setstate fail
/// `avoid_unnecessary_setstate`
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String _myString = '';
  final bool _condition = true;

  @override
  void initState() {
    super.initState();

    // expect_lint: avoid_unnecessary_setstate
    setState(() {
      _myString = "Hello";
    });

    if (_condition) {
      // expect_lint: avoid_unnecessary_setstate
      setState(() {
        _myString = "Hello";
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
      _myString = "Hello";
    });
  }

  void myStateUpdateMethod() {
    setState(() {
      _myString = "Hello";
    });
  }

  @override
  Widget build(BuildContext context) {
    // expect_lint: avoid_unnecessary_setstate
    setState(() {
      _myString = "Hello";
    });

    if (_condition) {
      // expect_lint: avoid_unnecessary_setstate
      setState(() {
        _myString = "Hello";
      });
    }

    // expect_lint: avoid_unnecessary_setstate
    myStateUpdateMethod();

    return ElevatedButton(
      onPressed: myStateUpdateMethod,
      onLongPress: () {
        setState(() {
          _myString = 'data';
        });
      },
      child: Text(_myString),
    );
  }
}
