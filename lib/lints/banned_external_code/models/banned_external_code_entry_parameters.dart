import 'package:analyzer/error/error.dart';
import 'package:solid_lints/utils/parameter_utils.dart';

/// A data model class that represents the "entries" input
/// parameters. All parameters are optional, which allows global variables,
/// classes, and entire packages to be linted.
///
/// Parameters:
/// * id: Variable/method name
/// * class_name: Name of the class containing the variable/method
/// * source: Package (e.g., dart:async or package:example)
/// * severity: The default severity of the lint for each entry.
/// * reason: Explain why the code is banned
///
/// Example:
/// ```yaml
/// entries:
///   - id: wait
///     class_name: Future
///     source: dart:async
///     reason: "Future.wait from dart:async isnt allowed"
///     severity: warning
/// ```
class BannedExternalCodeEntryParameters {
  /// Variable/method name
  final String? id;

  /// Name of the class containing the variable/method
  final String? className;

  /// Package (e.g., dart:async or package:example)
  final String? source;

  /// The default severity of the lint for each entry.
  final ErrorSeverity? severity;

  /// Explain why the code is banned
  final String? reason;

  /// Constructor for [BannedExternalCodeEntryParameters] model
  const BannedExternalCodeEntryParameters({
    this.id,
    this.className,
    this.source,
    this.severity,
    this.reason,
  });

  /// Method for creating from json data
  factory BannedExternalCodeEntryParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      BannedExternalCodeEntryParameters(
        id: json['id'] as String?,
        className: json['class_name'] as String?,
        source: json['source'] as String?,
        severity: decodeErrorSeverity(json['severity'] as String?),
        reason: json['reason'] as String?,
      );
}
