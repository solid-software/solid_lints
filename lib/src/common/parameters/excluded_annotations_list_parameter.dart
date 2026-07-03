import 'package:analyzer/dart/ast/ast.dart';

/// A parameter model representing excluded annotations for linting.
/// It defines class-level annotations that indicate when class members
/// should be ignored during analysis.
class ExcludedAnnotationsListParameter {
  /// The set of excluded annotation names.
  final Set<String> excludedAnnotations;

  /// A common parameter key for analysis_options.yaml
  static const String excludeAnnotationKey = 'exclude_annotation';

  /// Constructor for [ExcludedAnnotationsListParameter] class
  ExcludedAnnotationsListParameter({
    required this.excludedAnnotations,
  });

  /// Method for creating from json data
  factory ExcludedAnnotationsListParameter.fromJson(Map<String, dynamic> json) {
    final raw = json[excludeAnnotationKey];
    if (raw is List) {
      return ExcludedAnnotationsListParameter(
        excludedAnnotations: Set<String>.from(raw.whereType<String>()),
      );
    } else if (raw is String) {
      return ExcludedAnnotationsListParameter(
        excludedAnnotations: {raw},
      );
    }

    return ExcludedAnnotationsListParameter(
      excludedAnnotations: {},
    );
  }

  /// Returns whether the target node should be ignored during analysis because
  /// its enclosing declaration is annotated with one of the excluded
  /// annotations.
  bool shouldIgnore(Declaration node) {
    if (excludedAnnotations.isEmpty) return false;

    AstNode? current = node;
    while (current != null) {
      if (current is Declaration) {
        final hasAnnotation = current.metadata.any((annotation) {
          final name = annotation.name.name;
          final simpleName = name.split('.').last;
          return excludedAnnotations.contains(simpleName);
        });
        if (hasAnnotation) return true;
      }
      current = current.parent;
    }

    return false;
  }
}
