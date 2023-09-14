import 'package:collection/collection.dart';

/// A data model enum represents class member type affiliation
enum MemberType {
  /// Indicates fields affiliation
  field('fields'),

  /// Indicates method affiliation
  method('methods', typeAlias: 'method'),

  /// Indicates constructor affiliation
  constructor('constructors'),

  /// Indicates getters affiliation
  getter('getters'),

  /// Indicates setters affiliation
  setter('setters'),

  /// Indicates affiliation with both getters and setters
  getterAndSetter('getters-setters');

  /// String representation of member group type
  final String type;

  /// Alternative string representation of member group type
  final String? typeAlias;

  const MemberType(this.type, {this.typeAlias});

  /// Parses a String member type and returns instance of [MemberType]
  static MemberType? parse(String? name) => values
      .firstWhereOrNull((type) => name == type.type || name == type.typeAlias);
}
