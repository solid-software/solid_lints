import 'dart:collection';

import 'src/banned_library.dart';

void testingBannedCodeLint() {
  // expect_lint: banned_external_code
  final unmodifiable = UnmodifiableListView([1, 2, 3]);

  // expect_lint: banned_external_code
  final first = unmodifiable.first;
  print(first);

  // expect_lint: banned_external_code
  print(banned);
}
