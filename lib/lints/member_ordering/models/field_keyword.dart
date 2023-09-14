/// A data model enum represents field type keyword
enum FieldKeyword {
  /// final keyword
  isFinal('final'),

  /// const keyword
  isConst('const'),

  /// var keyword
  isVar('var'),

  /// Indicates missing field keyword
  /// used to handle cases of unsupported field type keywords
  unset('unset');

  /// String representation of field type keyword
  final String type;

  const FieldKeyword(this.type);

  /// Parses a String field type and returns instance of [FieldKeyword]
  static FieldKeyword parse(String? name) => values.firstWhere(
        (type) => type.type == name,
        orElse: () => FieldKeyword.unset,
      );
}
