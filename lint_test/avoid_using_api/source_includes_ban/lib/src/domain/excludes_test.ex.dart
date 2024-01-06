import 'dart:collection';

import 'package:external_source/banned_library.dart';

void testingBannedCodeLint() {
  final unmodifiable = UnmodifiableListView([1, 2, 3]);
  unmodifiable.first;
  banned;
}
