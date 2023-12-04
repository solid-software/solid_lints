import 'dart:collection';

void testingBannedCodeLint() {
  // expect_lint: banned_external_code
  final unmodifiable = UnmodifiableListView([1, 2, 3]);
  // expect_lint: banned_external_code
  unmodifiable.first;
}
