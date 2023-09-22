/// Check the `prefer-first` rule
void fun() {
  const zero = 0;
  final list = [0, 1, 2, 3];
  final set = {0, 1, 2, 3};
  final map = {0: 0, 1: 1, 2: 2, 3: 3};

  // expect_lint: prefer-first
  list[0];
  list[zero];
  // expect_lint: prefer-first
  list.elementAt(0);
  list.elementAt(zero);
  // expect_lint: prefer-first
  set.elementAt(0);

  // expect_lint: prefer-first
  map.keys.elementAt(0);
  // expect_lint: prefer-first
  map.values.elementAt(0);
}
