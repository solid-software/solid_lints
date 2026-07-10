import 'package:analyzer/error/error.dart';
import 'package:solid_lints/src/lints/avoid_using_api/models/avoid_using_api_entry_parameters.dart';
import 'package:solid_lints/src/utils/object_utils.dart';
import 'package:solid_lints/src/utils/parameter_utils.dart';
import 'package:yaml/yaml.dart';

/// A data model class that represents the "avoid_using_api" input
/// parameters.
///
/// Parameters:
/// * entries: A list of BannedCodeOption parameters.
///
/// Example:
/// ```yaml
/// plugins:
///   solid_lints:
///     diagnostics:
///       avoid_using_api:
///         avoid_using_api: error
///         entries:
///           - identifier: wait
///             class_name: Future
///             source: dart:async
///             reason: "Future.wait from dart:async isnt allowed"
///             severity: warning
/// ```
class AvoidUsingApiParameters {
  /// A list of BannedCodeOption parameters.
  final List<AvoidUsingApiEntryParameters> entries;

  /// The default severity of the lint for each entry.
  final DiagnosticSeverity? severity;

  /// Constructor for [AvoidUsingApiParameters] model
  const AvoidUsingApiParameters({
    this.entries = const [],
    this.severity,
  });

  /// Empty [AvoidUsingApiParameters] model.
  factory AvoidUsingApiParameters.empty() => const AvoidUsingApiParameters();

  /// Method for creating from json data
  factory AvoidUsingApiParameters.fromJson(
    Map<String, Object?> json,
  ) {
    final avoidUsingApi = json['avoid_using_api'];
    return AvoidUsingApiParameters(
      entries: List<AvoidUsingApiEntryParameters>.from(
        (json['entries'] as Iterable?)
            ?.whereType<Map<dynamic, dynamic>>()
            .map(
              (e) {
                if (e is YamlMap) {
                  return AvoidUsingApiEntryParameters.fromJson(e.toMap());
                }
                return AvoidUsingApiEntryParameters.fromJson(
                  Map<String, Object?>.from(e),
                );
              },
            ) ??
            [],
      ),
      severity: decodeErrorSeverity(
        json['severity'] as String? ??
            (avoidUsingApi is String ? avoidUsingApi : null),
      ),
    );
  }
}
