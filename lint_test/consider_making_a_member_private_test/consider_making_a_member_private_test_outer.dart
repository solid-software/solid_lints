// ignore_for_file: no_empty_block, prefer_match_file_name, unused_element, member_ordering, avoid_global_state, avoid_unused_parameters
import 'consider_making_a_member_private_test_inner.dart';

/// Check the `consider_making_a_member_private` rule
///

class Y {
  // no lint
  void _y() {
    final x = X();
    X.usedFactory();
    x.usedMethodX();
    usedGLobalFunction();
    usedGlobalVariables;
  }
}
