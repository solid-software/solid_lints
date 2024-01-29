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
/// * severity: The default severity of the lint for each entry.
///
/// Example:
/// ```yaml
/// custom_lint:
///   rules:
///     - avoid_using_api:
///       severity: error
///       entries:
///         - identifier: wait
///           class_name: Future
///           source: dart:async
///           reason: "Future.wait from dart:async isnt allowed"
///           severity: warning
/// ```
class AvoidUsingApiParameters {
  /// A list of BannedCodeOption parameters.
  final List<AvoidUsingApiEntryParameters> entries;

  /// The default severity of the lint for each entry.
  final ErrorSeverity? severity;

  /// Constructor for [AvoidUsingApiParameters] model
  const AvoidUsingApiParameters({
    this.entries = const [],
    this.severity,
  });

  /// Method for creating from json data
  factory AvoidUsingApiParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      AvoidUsingApiParameters(
        entries: List<AvoidUsingApiEntryParameters>.from(
          (json['entries'] as Iterable?)?.map(
                (e) => AvoidUsingApiEntryParameters.fromJson(
                  (e as YamlMap).toMap(),
                ),
              ) ??
              [],
        ),
        severity: decodeErrorSeverity(json['severity'] as String?),
      );
}
