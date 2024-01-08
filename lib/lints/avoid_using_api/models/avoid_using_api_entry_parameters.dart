import 'package:analyzer/error/error.dart';
import 'package:solid_lints/utils/parameter_utils.dart';

/// A data model class that represents the "entries" input
/// parameters. All parameters are optional, which allows global variables,
/// classes, and entire packages to be linted.
///
/// Parameters:
/// * identifier: Variable/method name
/// * class_name: Name of the class containing the variable/method
/// * source: Package (e.g., dart:async or package:example)
/// * severity: The default severity of the lint for each entry.
/// * reason: Explain why the code is banned
/// * includes: Glob patterns for files to include
/// * excludes: Glob patterns for files to exclude
///
/// Note:
/// * `source` must not be from the same package as the project you are trying
///   to check for lints. Use `@Deprecated` instead.
///
/// Example:
/// ```yaml
/// entries:
///   - identifier: wait
///     class_name: Future
///     source: dart:async
///     reason: "Future.wait from dart:async isnt allowed"
///     severity: warning
///     includes: []
///     excludes: []
/// ```
class AvoidUsingApiEntryParameters {
  /// Variable/method name
  final String? identifier;

  /// Name of the class containing the variable/method
  final String? className;

  /// Package (e.g., dart:async or package:example)
  final String? source;

  /// The default severity of the lint for each entry.
  final ErrorSeverity? severity;

  /// Explain why the code is banned
  final String? reason;

  /// Regex patterns for files to include
  final List<String> includes;

  /// Regex patterns for files to exclude
  final List<String> excludes;

  /// Constructor for [AvoidUsingApiEntryParameters] model
  const AvoidUsingApiEntryParameters({
    this.identifier,
    this.className,
    this.source,
    this.severity,
    this.reason,
    this.includes = const [],
    this.excludes = const [],
  });

  /// Method for creating from json data
  factory AvoidUsingApiEntryParameters.fromJson(
    Map<String, Object?> json,
  ) =>
      AvoidUsingApiEntryParameters(
        identifier: json['identifier'] as String?,
        className: json['class_name'] as String?,
        source: json['source'] as String?,
        severity: decodeErrorSeverity(json['severity'] as String?),
        reason: json['reason'] as String?,
        includes: (json['includes'] as List<Object?>? ?? [])
            .whereType<String>()
            .toList(),
        excludes: (json['excludes'] as List<Object?>? ?? [])
            .whereType<String>()
            .toList(),
      );
}
