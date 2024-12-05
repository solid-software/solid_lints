// ignore_for_file: no_empty_block, prefer_match_file_name, unused_element, member_ordering
/// Check the `consider_making_a_member_private` rule
///

class X {
  // expect_lint:consider_making_a_member_private
  void unusedX() {}

// no lint
  void usedX() {}
}

class Y {
  // no lint
  void _y() {
    final x = X();
    x.usedX();
  }
}
