/// A data model enum represents class member access modifier
enum Modifier {
  /// Indicates public access modifier
  public('public'),

  /// Indicates private access modifier
  private('private'),

  /// Indicates missing access modifier
  /// used to handle cases of unsupported field type keywords
  unset('unset');

  /// String representation of access modifier keyword
  final String type;

  const Modifier(this.type);

  /// Parses a String access modifier and returns instance of [Modifier]
  static Modifier parse(String? name) => values
      .firstWhere((type) => type.type == name, orElse: () => Modifier.unset);
}
