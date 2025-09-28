import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

// Useful types for testing expressions' types

// TODO: consider to move here common functions for rules
// avoid_unnecessary_type_assertions
// avoid_unnecessary_type_casts (after implementation)
// avoid_unrelated_type_assertions (after implementation)

/// A class for representing arguments for types checking methods
class TypeCast {
  /// The static type ot the tested expression
  final DartType source;

  /// The type being tested for
  final DartType target;

  /// Set to true for opposite comparison, i.e 'is!'
  final bool isReversed;

  /// Creates a new Typecast object with a given expression's or object's type
  /// and a tested type
  TypeCast({
    required this.source,
    required this.target,
    this.isReversed = false,
  });

  /// Checks that type checking is unnecessary
  bool get isUnnecessaryTypeCheck {
    final source = this.source;

    if (_isNullableCompatibility) {
      return false;
    }

    if (source.element == target.element) {
      return _areGenericsWithSameTypeArgs;
    }

    if (source is InterfaceType) {
      return source.allSupertypes.any(
        (e) => e.element == target.element,
      );
    }

    return false;
  }

  /// Checks for nullable type casts
  /// Only one case `Type? is Type` always valid assertion case.
  bool get _isNullableCompatibility {
    final isObjectTypeNullable =
        source.nullabilitySuffix != NullabilitySuffix.none;
    final isCastedTypeNullable =
        target.nullabilitySuffix != NullabilitySuffix.none;

    return isObjectTypeNullable && !isCastedTypeNullable;
  }

  /// Checks for type arguments and compares them
  bool get _areGenericsWithSameTypeArgs {
    if (source is DynamicType || target is DynamicType) {
      return false;
    }

    if (this
        case TypeCast(
          source: final objectType,
          target: final castedType,
        )
        when objectType is ParameterizedType &&
            castedType is ParameterizedType) {
      if (objectType.typeArguments.length != castedType.typeArguments.length) {
        return false;
      }

      return IterableZip([objectType.typeArguments, castedType.typeArguments])
          .map((e) => TypeCast(source: e[0], target: e[1]))
          .every((cast) => cast.isUnnecessaryTypeCheck);
    } else {
      return false;
    }
  }
}
