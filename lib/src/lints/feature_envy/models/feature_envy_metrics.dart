import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:solid_lints/src/lints/feature_envy/models/feature_envy_parameters.dart';

/// Calculated Feature Envy metrics for a method.
class FeatureEnvyMetrics {
  /// Locality of Attribute Access (LAA) metric.
  final double laa;

  /// Foreign Data Providers (FDP) metric.
  final int fdp;

  /// Access to Foreign Data (ATFD) metric.
  final int atfd;

  /// The class element that is accessed the most externally.
  final InterfaceElement? maxEnvyElement;

  const FeatureEnvyMetrics._({
    required this.laa,
    required this.fdp,
    required this.atfd,
    required this.maxEnvyElement,
  });

  /// Checks if these metrics exceed the thresholds defined in [parameters],
  /// indicating a feature envy code smell.
  bool exceedsThresholds(FeatureEnvyParameters parameters) =>
      atfd >= parameters.atfdThreshold &&
      laa < parameters.laaThreshold &&
      fdp <= parameters.fdpThreshold;

  /// Calculates metrics based on collected accesses.
  factory FeatureEnvyMetrics.calculate({
    required int internalAccesses,
    required Map<InterfaceElement, int> externalAccessCounts,
  }) {
    final totalExternalAccesses = externalAccessCounts.values.sum;
    final totalAccesses = internalAccesses + totalExternalAccesses;

    final laa = totalAccesses == 0 ? 1.0 : internalAccesses / totalAccesses;
    final fdp = externalAccessCounts.length;

    final maxEntry = externalAccessCounts.entries
        .sorted((a, b) => b.value != a.value
            ? b.value.compareTo(a.value)
            : (a.key.name ?? '').compareTo(b.key.name ?? ''))
        .firstOrNull;

    return FeatureEnvyMetrics._(
      laa: laa,
      fdp: fdp,
      atfd: maxEntry?.value ?? 0,
      maxEnvyElement: maxEntry?.key,
    );
  }
}
