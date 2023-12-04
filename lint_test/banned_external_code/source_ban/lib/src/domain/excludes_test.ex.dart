import 'dart:collection';

void testingBannedCodeLint() {
  final unmodifiable = UnmodifiableListView([1, 2, 3]);
  unmodifiable.first;
}
