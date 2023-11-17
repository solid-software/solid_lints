// ignore_for_file: prefer_match_file_name

import 'package:flutter/material.dart';

/// Check "check super" keyword fail
///
/// `proper_super_calls`
class ProperSuperCallsTest1 extends StatefulWidget {
  @override
  State<ProperSuperCallsTest1> createState() => _ProperSuperCallsTest1State();

  const ProperSuperCallsTest1({super.key});
}

class _ProperSuperCallsTest1State extends State<ProperSuperCallsTest1> {
   
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // expect_lint: proper_super_calls
  @override
  void initState() {
    print('');
    super.initState();
  }
  
  // expect_lint: proper_super_calls
  @override
  void dispose() {
    super.dispose();
    print('');
  }
}

class ProperSuperCallsTest2 extends StatefulWidget {
  @override
  State<ProperSuperCallsTest2> createState() => _ProperSuperCallsTest2State();

  const ProperSuperCallsTest2({super.key});
}

class _ProperSuperCallsTest2State extends State<ProperSuperCallsTest2> {
   
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    print(''); 
  }

  @override
  void dispose() {
    print('');
    super.dispose();
  }
}

class ProperSuperCallsTest3 extends StatefulWidget {
  @override
  State<ProperSuperCallsTest3> createState() => _ProperSuperCallsTest3State();

  const ProperSuperCallsTest3({super.key});
}

class _ProperSuperCallsTest3State extends State<ProperSuperCallsTest3> {
   
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // expect_lint: proper_super_calls
  @override
  void initState() {
    print(''); 
  }

  // expect_lint: proper_super_calls
  @override
  void dispose() {
    print('');
  }
}