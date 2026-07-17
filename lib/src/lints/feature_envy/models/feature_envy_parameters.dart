import 'package:solid_lints/src/common/parameters/excluded_identifiers_list_parameter.dart';

/// Configuration parameters for the feature_envy rule.
class FeatureEnvyParameters {
  /// A list of methods that should be excluded from the lint.
  final ExcludedIdentifiersListParameter exclude;

  /// Access to Foreign Data (ATFD) threshold.
  /// Triggered if ATFD >= atfdThreshold.
  final int atfdThreshold;

  /// Locality of Attribute Access (LAA) threshold.
  /// Triggered if LAA < laaThreshold.
  final double laaThreshold;

  /// Foreign Data Providers (FDP) threshold.
  /// Triggered only if FDP <= fdpThreshold.
  final int fdpThreshold;

  /// Default Access to Foreign Data (ATFD) threshold.
  static const _defaultAtfdThreshold = 4;

  /// Default Locality of Attribute Access (LAA) threshold.
  static const _defaultLaaThreshold = 0.33;

  /// Default Foreign Data Providers (FDP) threshold.
  static const _defaultFdpThreshold = 2;

  /// Constructor for [FeatureEnvyParameters] model.
  const FeatureEnvyParameters({
    required this.atfdThreshold,
    required this.exclude,
    required this.laaThreshold,
    required this.fdpThreshold,
  });

  /// Empty [FeatureEnvyParameters] model with default values.
  factory FeatureEnvyParameters.empty() => FeatureEnvyParameters(
    atfdThreshold: _defaultAtfdThreshold,
    exclude: ExcludedIdentifiersListParameter(exclude: []),
    laaThreshold: _defaultLaaThreshold,
    fdpThreshold: _defaultFdpThreshold,
  );

  /// Creates a [FeatureEnvyParameters] model from JSON data.
  factory FeatureEnvyParameters.fromJson(Map<String, Object?> json) {
    final atfdThreshold = switch (json['atfd_threshold']) {
      final int value => value,
      _ => _defaultAtfdThreshold,
    };

    final laaThreshold = switch (json['laa_threshold']) {
      final double value => value,
      final int value => value.toDouble(),
      _ => _defaultLaaThreshold,
    };

    final fdpThreshold = switch (json['fdp_threshold']) {
      final int value => value,
      _ => _defaultFdpThreshold,
    };

    return FeatureEnvyParameters(
      exclude: ExcludedIdentifiersListParameter.defaultFromJson(json),
      atfdThreshold: atfdThreshold,
      laaThreshold: laaThreshold,
      fdpThreshold: fdpThreshold,
    );
  }
}
