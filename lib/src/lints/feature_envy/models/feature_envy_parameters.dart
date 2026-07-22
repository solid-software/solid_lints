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
    required this.exclude,
    required this.atfdThreshold,
    required this.laaThreshold,
    required this.fdpThreshold,
  });

  /// Empty [FeatureEnvyParameters] model with default values.
  FeatureEnvyParameters.empty()
    : exclude = ExcludedIdentifiersListParameter(exclude: []),
      atfdThreshold = _defaultAtfdThreshold,
      laaThreshold = _defaultLaaThreshold,
      fdpThreshold = _defaultFdpThreshold;

  /// Creates a [FeatureEnvyParameters] model from JSON data.
  FeatureEnvyParameters.fromJson(Map<String, Object?> json)
    : exclude = ExcludedIdentifiersListParameter.defaultFromJson(json),
      atfdThreshold = json['atfd_threshold'] as int? ?? _defaultAtfdThreshold,
      laaThreshold =
          (json['laa_threshold'] as num?)?.toDouble() ?? _defaultLaaThreshold,
      fdpThreshold = json['fdp_threshold'] as int? ?? _defaultFdpThreshold;
}
