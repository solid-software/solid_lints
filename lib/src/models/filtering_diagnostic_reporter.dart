import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:solid_lints/src/common/parameter_parser/analysis_options_loader.dart';

/// A [DiagnosticReporter] decorator that suppresses diagnostic reporting
/// for AST nodes located in files excluded by analysis options.
class FilteringDiagnosticReporter extends DiagnosticReporter {
  final DiagnosticReporter _delegate;
  final AnalysisOptionsLoader _loader;

  /// Creates a new instance of [FilteringDiagnosticReporter].
  FilteringDiagnosticReporter(this._delegate, this._loader)
    : super(DiagnosticListener.nullListener, _delegate.source);

  @override
  Diagnostic atNode(
    AstNode node,
    DiagnosticCode diagnosticCode, {
    List<Object>? arguments,
    List<DiagnosticMessage>? contextMessages,
  }) {
    final filePath = switch (node.root) {
      CompilationUnit(:final declaredFragment?) =>
        declaredFragment.source.fullName,
      _ => _delegate.source.fullName,
    };

    if (_loader.isFileExcludedForFile(filePath)) {
      return _suppressedDiagnostic(diagnosticCode, node.offset, node.length);
    }

    return _delegate.atNode(
      node,
      diagnosticCode,
      arguments: arguments,
      contextMessages: contextMessages,
    );
  }

  @override
  Diagnostic atOffset({
    required int offset,
    required int length,
    required DiagnosticCode diagnosticCode,
    List<Object>? arguments,
    List<DiagnosticMessage>? contextMessages,
  }) {
    if (_loader.isFileExcludedForFile(_delegate.source.fullName)) {
      return _suppressedDiagnostic(diagnosticCode, offset, length);
    }

    return _delegate.atOffset(
      offset: offset,
      length: length,
      diagnosticCode: diagnosticCode,
      arguments: arguments,
      contextMessages: contextMessages,
    );
  }

  @override
  Diagnostic atToken(
    Token token,
    DiagnosticCode diagnosticCode, {
    List<Object>? arguments,
    List<DiagnosticMessage>? contextMessages,
  }) {
    if (_loader.isFileExcludedForFile(_delegate.source.fullName)) {
      return _suppressedDiagnostic(diagnosticCode, token.offset, token.length);
    }

    return _delegate.atToken(
      token,
      diagnosticCode,
      arguments: arguments,
      contextMessages: contextMessages,
    );
  }

  Diagnostic _suppressedDiagnostic(
    DiagnosticCode diagnosticCode,
    int offset,
    int length,
  ) => Diagnostic.tmp(
    source: _delegate.source,
    offset: offset,
    length: length,
    diagnosticCode: diagnosticCode,
  );
}
