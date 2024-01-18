import 'dart:collection';

import 'package:external_source/banned_library.dart';

void testingBannedCodeLint() {
  // expect_lint: avoid_using_api
  final unmodifiable = UnmodifiableListView([1, 2, 3]);

  // expect_lint: avoid_using_api
  unmodifiable.first;

  // expect_lint: avoid_using_api
  banned;
}
