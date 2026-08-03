// MIT License
//
// Copyright (c) 2020-2021 Dart Code Checker team
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:solid_lints/src/utils/named_type_utils.dart';

extension Subtypes on DartType {
  Iterable<DartType> get supertypes {
    final element = this.element;
    return element is InterfaceElement ? element.allSupertypes : [];
  }

  /// Formats the type string based on nullability and presence of generics.
  String getTypeString({
    required bool withGenerics,
    required bool withNullability,
  }) {
    final displayString = getDisplayString();

    return withGenerics ? displayString : displayString.replaceGenericString();
  }

  /// Parses a [NamedType] instance from current type.
  NamedType getNamedType() {
    final typeString = getTypeString(
      withGenerics: true,
      withNullability: false,
    );

    return parseNamedTypeFromString(typeString);
  }

  /// Checks if a variable type is among the ignored types.
  bool hasIgnoredType({required Set<String> ignoredTypes}) {
    if (ignoredTypes.isEmpty) return false;

    final checkedTypeNodes = [this, ...supertypes].map(
      (type) => type.getNamedType(),
    );

    final ignoredTypeNodes = ignoredTypes.map(parseNamedTypeFromString);

    for (final ignoredTypeNode in ignoredTypeNodes) {
      for (final checkedTypeNode in checkedTypeNodes) {
        if (ignoredTypeNode.isSubtypeOf(node: checkedTypeNode)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Compares this type with [other] ignoring nullability where applicable.
  bool isDifferentIgnoringNullability(DartType? other) =>
      other != null && (element ?? this) != (other.element ?? other);
}

extension TypeString on String {
  static final _genericRegex = RegExp('<.*>');

  String replaceGenericString() => replaceFirst(_genericRegex, '');
}

extension _PropertyAccessorElementExt on PropertyAccessorElement {
  bool get isPublicInstanceOrigin =>
      isPublic && !isStatic && isOriginDeclaration;
}

extension _PropertyAccessorsExt on Iterable<PropertyAccessorElement> {
  Iterable<String> get publicInstanceMemberNames =>
      where((e) => e.isPublicInstanceOrigin).map((e) => e.displayName);
}

extension InterfaceElementExt on InterfaceElement {
  /// Checks whether this element is the same as or a subclass of [superType].
  bool isSameOrSubclassOf(InterfaceElement superType) =>
      this == superType ||
      allSupertypes.any((type) => type.element == superType);

  /// Checks if a class is a Data Class based on Weight of Class.
  bool get isDataClass {
    const dataClassWeightThreshold = 0.33;

    final elements = [
      this,
      ...allSupertypes.where((s) => !s.isDartCoreObject).map((s) => s.element),
    ];

    final publicProperties = {
      for (final el in elements) ...[
        ...el.getters.publicInstanceMemberNames.toSet().difference({
          'hashCode',
          'runtimeType',
        }),
        ...el.setters.publicInstanceMemberNames,
      ],
    };

    final publicMethods = elements
        .expand((e) => e.methods)
        .where((m) => m.isPublic && !m.isStatic)
        .map((m) => m.name)
        .nonNulls
        .toSet()
        .difference({
          'toString',
          '==',
          'copyWith',
          'toJson',
          'noSuchMethod',
        });

    final totalMembers = publicProperties.length + publicMethods.length;
    if (totalMembers == 0) return true;

    final weightOfClass = publicMethods.length / totalMembers;
    return weightOfClass < dataClassWeightThreshold;
  }
}

bool isWidgetType(DartType type) =>
    isWidgetOrSubclass(type) &&
    !(_isMultiProvider(type) || _isSubclassOfInheritedProvider(type));

bool isIterable(DartType? type) =>
    _checkSelfOrSupertypes(type, (t) => t?.isDartCoreIterable ?? false);

bool isNullableType(DartType? type) =>
    type?.nullabilitySuffix == NullabilitySuffix.question;

bool isWidgetOrSubclass(DartType? type) =>
    _isWidget(type) || _isSubclassOfWidget(type);

bool isRenderObjectOrSubclass(DartType? type) =>
    _isRenderObject(type) || _isSubclassOfRenderObject(type);

bool isRenderObjectWidgetOrSubclass(DartType? type) =>
    _isRenderObjectWidget(type) || _isSubclassOfRenderObjectWidget(type);

bool isRenderObjectElementOrSubclass(DartType? type) =>
    _isRenderObjectElement(type) || _isSubclassOfRenderObjectElement(type);

bool isWidgetStateOrSubclass(DartType? type) =>
    _isWidgetState(type) || _isSubclassOfWidgetState(type);

bool isSubclassOfListenable(DartType? type) =>
    type is InterfaceType && type.allSupertypes.any(_isListenable);

bool isListViewWidget(DartType? type) => type?.getDisplayString() == 'ListView';

bool isSingleChildScrollViewWidget(DartType? type) =>
    type?.getDisplayString() == 'SingleChildScrollView';

bool isColumnWidget(DartType? type) => type?.getDisplayString() == 'Column';

bool isRowWidget(DartType? type) => type?.getDisplayString() == 'Row';

bool isPaddingWidget(DartType? type) => type?.getDisplayString() == 'Padding';

bool isBuildContext(DartType? type) {
  if (type == null) return false;
  final displayString = type.getDisplayString();
  return displayString == 'BuildContext' || displayString == 'BuildContext?';
}

bool isGameWidget(DartType? type) => type?.getDisplayString() == 'GameWidget';

bool _checkSelfOrSupertypes(
  DartType? type,
  bool Function(DartType?) predicate,
) =>
    predicate(type) ||
    (type is InterfaceType && type.allSupertypes.any(predicate));

bool _isWidget(DartType? type) =>
    type is InterfaceType && type.element.name == 'Widget';

bool _isSubclassOfWidget(DartType? type) =>
    type is InterfaceType && type.allSupertypes.any(_isWidget);

bool _isWidgetState(DartType? type) =>
    type is InterfaceType && type.element.name == 'State';

bool _isSubclassOfWidgetState(DartType? type) =>
    type is InterfaceType && type.allSupertypes.any(_isWidgetState);

bool _isListenable(DartType type) =>
    type is InterfaceType && type.element.name == 'Listenable';

bool _isRenderObject(DartType? type) =>
    type is InterfaceType && type.element.name == 'RenderObject';

bool _isSubclassOfRenderObject(DartType? type) =>
    type is InterfaceType && type.allSupertypes.any(_isRenderObject);

bool _isRenderObjectWidget(DartType? type) =>
    type is InterfaceType && type.element.name == 'RenderObjectWidget';

bool _isSubclassOfRenderObjectWidget(DartType? type) =>
    type is InterfaceType && type.allSupertypes.any(_isRenderObjectWidget);

bool _isRenderObjectElement(DartType? type) =>
    type is InterfaceType && type.element.name == 'RenderObjectElement';

bool _isSubclassOfRenderObjectElement(DartType? type) =>
    type is InterfaceType && type.allSupertypes.any(_isRenderObjectElement);

bool _isMultiProvider(DartType? type) =>
    type?.getDisplayString() == 'MultiProvider';

bool _isSubclassOfInheritedProvider(DartType? type) =>
    type is InterfaceType && type.allSupertypes.any(_isInheritedProvider);

bool _isInheritedProvider(DartType? type) =>
    type != null && type.getDisplayString().startsWith('InheritedProvider<');

bool isIterableOrSubclass(DartType? type) =>
    _checkSelfOrSupertypes(type, (t) => t?.isDartCoreIterable ?? false);

bool isListOrSubclass(DartType? type) =>
    _checkSelfOrSupertypes(type, (t) => t?.isDartCoreList ?? false);
