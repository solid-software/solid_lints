// ignore_for_file: type_annotate_public_apis, prefer_match_file_name, unused_local_variable, consider_making_a_member_private

/// Check global mutable variable fail
/// `avoid_global_state`

// expect_lint: avoid_global_state
var globalMutable = 0;

final globalFinal = 1;

const globalConst = 1;

class Test {
  static final int globalFinal = 1;

  // expect_lint: avoid_global_state
  static int globalMutable = 0;

  final int memberFinal = 1;

  int memberMutable = 0;

  void m() {
    int localMutable = 0;

    final localFinal = 1;

    const localConst = 2;
  }
}
