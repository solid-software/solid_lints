// ignore_for_file: type_annotate_public_apis, prefer-match-file-name

/// Check global mutable variable fail
/// `avoid_global_state`

// expect_lint: avoid_global_state
var globalMutable = 0;

class Test {
  // expect_lint: avoid_global_state
  static int globalMutable = 0;
}
