// ignore_for_file: no_empty_block, prefer_match_file_name, unused_element, member_ordering, avoid_global_state, avoid_unused_parameters
/// Check the `consider_making_a_member_private` rule
///

// expect_lint:consider_making_a_member_private
const int unusedGlobalVariables = 0;

//no lint
const int usedGlobalVariables = 0;

// expect_lint:consider_making_a_member_private
void unusedGLobalFunction() {}

//no lint
void usedGLobalFunction() {}

class X {
  // expect_lint:consider_making_a_member_private
  void unusedX() {}

  // expect_lint:consider_making_a_member_private
  final int unusedFinalX = 0;
  // expect_lint:consider_making_a_member_private
  static final int unusedStaticX = 0;

  // expect_lint:consider_making_a_member_private
  int unusedMutableX = 0;

  // expect_lint:consider_making_a_member_private
  int get unusedGetX => 0;

  // expect_lint:consider_making_a_member_private
  set unusedSetX(int y) {}

  // no lint
  void usedMethodX() {}

  // expect_lint:consider_making_a_member_private
  static void unusedStaticMethodX() {}

  // no lint
  X();

  // expect_lint:consider_making_a_member_private
  X.withValue({
    required this.unusedMutableX,
  });

  // expect_lint:consider_making_a_member_private
  factory X.factory() => X();

  // no lint
  factory X.usedFactory() => X();
}
