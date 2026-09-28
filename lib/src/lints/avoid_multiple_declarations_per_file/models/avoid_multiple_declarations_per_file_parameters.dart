import 'package:analyzer/dart/ast/ast.dart';
import 'package:solid_lints/src/common/parameters/excluded_entities_list_parameter.dart';
import 'package:solid_lints/src/common/parameters/ignored_types_list_parameter.dart';
import 'package:solid_lints/src/utils/node_utils.dart';

/// A data model class that represents the "avoid multiple declarations per
/// file" input parameters.
class AvoidMultipleDeclarationsPerFileParameters {
  /// Types and their subtypes that should be ignored as violations.
  ///
  /// Example:
  ///
  /// ```yaml
  /// solid_lints:
  ///   diagnostics:
  ///     avoid_multiple_declarations_per_file:
  ///       ignored_types:
  ///         - State
  /// ```
  ///
  /// ```dart
  /// class MyWidget extends StatefulWidget {}
  ///
  /// class _MyWidgetState extends State<MyWidget> {} // OK
  /// ```
  final IgnoredTypesListParameter ignoredTypes;

  /// AST entities (e.g. enum, mixin, extension, extension_type) to exclude.
  ///
  /// Example:
  ///
  /// ```yaml
  /// solid_lints:
  ///   diagnostics:
  ///     avoid_multiple_declarations_per_file:
  ///       exclude_entity:
  ///         - extension_type
  ///         - enum
  /// ```
  ///
  /// ```dart
  /// class User {}
  ///
  /// extension type UserId(int id) {} // OK
  ///
  /// enum UserRole { admin, regular } // OK
  /// ```
  final ExcludedEntitiesListParameter excludedEntities;

  /// Whether private declarations (e.g. prefixed with `_`) are allowed.
  ///
  /// Example:
  ///
  /// ```yaml
  /// solid_lints:
  ///   diagnostics:
  ///     avoid_multiple_declarations_per_file:
  ///       allow_private: true
  /// ```
  ///
  /// ```dart
  /// class PublicClass {}
  ///
  /// class _PrivateHelper {} // OK
  /// ```
  final bool allowPrivate;

  /// Maximum lines of code allowed for secondary declarations.
  ///
  /// Example:
  ///
  /// ```yaml
  /// solid_lints:
  ///   diagnostics:
  ///     avoid_multiple_declarations_per_file:
  ///       maximum_loc: 10
  /// ```
  ///
  /// ```dart
  /// class MainClass {}
  ///
  /// class SmallHelper {
  ///   void run() {}
  /// } // OK if LOC <= 10
  /// ```
  final int? maximumLoc;

  /// Constructor for [AvoidMultipleDeclarationsPerFileParameters].
  const AvoidMultipleDeclarationsPerFileParameters({
    required this.ignoredTypes,
    required this.excludedEntities,
    this.allowPrivate = false,
    this.maximumLoc,
  });

  /// Empty parameters model with default values.
  factory AvoidMultipleDeclarationsPerFileParameters.empty() =>
      AvoidMultipleDeclarationsPerFileParameters(
        ignoredTypes: IgnoredTypesListParameter.empty(),
        excludedEntities: ExcludedEntitiesListParameter(
          excludedEntityNames: {},
        ),
      );

  /// Method for creating parameters from JSON configuration.
  factory AvoidMultipleDeclarationsPerFileParameters.fromJson(
    Map<String, Object?> json,
  ) => AvoidMultipleDeclarationsPerFileParameters(
    ignoredTypes: IgnoredTypesListParameter.fromJson(json),
    excludedEntities: ExcludedEntitiesListParameter.fromJson(json),
    allowPrivate: json['allow_private'] as bool? ?? false,
    maximumLoc: json['maximum_loc'] as int?,
  );

  /// Returns `true` if the given [node] should be ignored based on
  /// [excludedEntities] or [ignoredTypes].
  bool shouldIgnore(CompilationUnitMember node) =>
      excludedEntities.shouldIgnoreEntity(node) ||
      ignoredTypes.shouldIgnore(node.declaredType);
}
