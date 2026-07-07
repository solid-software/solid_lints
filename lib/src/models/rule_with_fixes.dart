import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';

/// A function that creates a [CorrectionProducer] for a given context.
typedef ProducerGenerator =
    CorrectionProducer<ParsedUnitResult> Function({
      required CorrectionProducerContext context,
    });

/// An interface for lint rules that have associated quick fixes.
abstract interface class RuleWithFixes {
  /// Returns the map entries of diagnostic code and its associated fix
  /// generator.
  Iterable<MapEntry<DiagnosticCode, ProducerGenerator>> get fixesForCodes;
}
