// ignore_for_file: consider_making_a_member_private
/// Check the `prefer_first` rule
void fun() {
  final list = [0, 1, 2, 3];
  final length = list.length - 1;
  final set = {0, 1, 2, 3};
  final map = {0: 0, 1: 1, 2: 2, 3: 3};

  // expect_lint: prefer_last
  list[list.length - 1];

  list[length - 1];

  // expect_lint: prefer_last
  list.elementAt(list.length - 1);
  list.elementAt(length - 1);

  // expect_lint: prefer_last
  set.elementAt(set.length - 1);

  // expect_lint: prefer_last
  map.keys.elementAt(map.keys.length - 1);

  // expect_lint: prefer_last
  map.values.elementAt(map.values.length - 1);
}
