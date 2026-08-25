import 'package:analyzer/diagnostic/diagnostic.dart';

/// A concrete implementation of [DiagnosticMessage] for reporting diagnostics
/// with context messages in solid_lints rules.
class SolidDiagnosticMessage implements DiagnosticMessage {
  @override
  final String filePath;

  @override
  final int length;

  @override
  final int offset;

  @override
  String? get url => null;

  final String _message;

  /// Creates a new instance of [SolidDiagnosticMessage].
  SolidDiagnosticMessage({
    required this.filePath,
    required this.length,
    required this._message,
    required this.offset,
  });

  @override
  String messageText({required bool includeUrl}) {
    return _message;
  }
}
