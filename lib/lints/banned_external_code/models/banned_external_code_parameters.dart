import 'package:analyzer/error/error.dart';
import 'package:solid_lints/lints/banned_external_code/models/banned_external_code_entry_parameters.dart';
import 'package:solid_lints/utils/parameter_utils.dart';

/// A data model class that represents the "banned_external_code" input
/// parameters.
///
/// Parameters:
/// * entries: A list of BannedCodeOption parameters.
/// * severity: The default severity of the lint for each entry.
///
/// Example:
/// ```yaml
/// rules:
///   - banned_code:
///     severity: error
///     entries:
///       - id: waitAll
///         class_name: Future
///         source: dart:async
///         reason: "Future.waitAll from dart:async isnt allowed"
///         severity: warning
/// ```
class BannedExternalCodeParameters {
  /// A list of BannedCodeOption parameters.
  final List<BannedExternalCodeEntryParameters> entries;

  /// The default severity of the lint for each entry.
  final ErrorSeverity? severity;

  /// Constructor for [BannedExternalCodeParameters] model
  const BannedExternalCodeParameters({
    this.entries = const [],
    this.severity,
  });

  /// Method for creating from json data
  factory BannedExternalCodeParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      BannedExternalCodeParameters(
        entries: List<BannedExternalCodeEntryParameters>.from(
          (json['entries'] as Iterable?)?.map(
                (e) => BannedExternalCodeEntryParameters.fromJson(
                  e as Map<String, Object?>,
                ),
              ) ??
              [],
        ),
        severity: decodeErrorSeverity(json['severity'] as String?),
      );
}
