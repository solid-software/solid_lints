// ignore_for_file: prefer_match_file_name, no_empty_block

class Widget {}

abstract class State<T> {
  build();
  dispose() {}
  initState() {}
}

abstract class StatefulWidget extends Widget {
  State createState();

  StatefulWidget();
}

/// Check "check super" keyword fail
///
/// `proper_super_calls`
class ProperSuperCallsTest1 extends StatefulWidget {
  @override
  State<ProperSuperCallsTest1> createState() => _ProperSuperCallsTest1State();

  ProperSuperCallsTest1();
}

class _ProperSuperCallsTest1State extends State<ProperSuperCallsTest1> {
  @override
  Widget build() {
    return Widget();
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

  ProperSuperCallsTest2();
}

class _ProperSuperCallsTest2State extends State<ProperSuperCallsTest2> {
  @override
  Widget build() {
    return Widget();
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

class MyClass {
  dispose() {}
  initState() {}
}

abstract interface class Disposable {
  /// Abstract methods should be omitted by `proper_super_calls`
  void dispose();
}

class ProperSuperCallsTest3 extends StatefulWidget {
  @override
  State<ProperSuperCallsTest3> createState() => _ProperSuperCallsTest3State();

  ProperSuperCallsTest3();
}

class _ProperSuperCallsTest3State extends State<ProperSuperCallsTest3> {
  @override
  Widget build() {
    return Widget();
  }

  @override
  Future<void> initState() async {
    await super.initState();
    print('');
  }

  @override
  Future<void> dispose() async {
    print('');
    await super.dispose();
  }
}


