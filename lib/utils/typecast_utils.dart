import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

// Useful types for testing expressions' types

// TODO: consider to move here common functions for rules
// avoid-unnecessary-type-assertions
// avoid-unnecessary-type-casts (after implementation)
// avoid-unrelated-type-assertions (after implementation)

/// A class for representing arguments for types checking methods
class TypeCast {
  /// The static type ot the tested expression
  final DartType source;

  /// The type being tested for
  final DartType target;

  /// Creates a new Typecast object with a given expression's or object's type
  /// and a tested type
  TypeCast({required this.source, required this.target});

  /// Returns the first type from source's supertypes
  /// which is corresponding to target or null
  DartType? castTypeInHierarchy() {
    if (source.element == target.element) {
      return source;
    }

    final objectType = source;
    if (objectType is InterfaceType) {
      return objectType.allSupertypes.firstWhereOrNull(
        (value) => value.element == target.element,
      );
    }

    return null;
  }
}
