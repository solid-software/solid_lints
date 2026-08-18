import 'package:analyzer/source/source.dart';

/// A fake implementation of [Source] for model tests.
class FakeSource implements Source {
  @override
  final String fullName;

  /// Creates a new instance of [FakeSource].
  FakeSource(this.fullName);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
