/// A data model enum represents annotation
enum Annotation {
  /// override annotation
  override('override', 'overridden'),

  /// protected annotation
  protected('protected'),

  /// Indicates missing annotation
  /// used to handle cases of unsupported annotations
  unset('unset');

  /// String representation of name of an annotation
  final String name;

  /// String representation of public name of an annotation
  final String? publicName;

  const Annotation(this.name, [this.publicName]);

  /// Parses a String name and returns instance of [Annotation]
  static Annotation parse(String? name) => values.firstWhere(
        (annotation) =>
            annotation.name == name ||
            (annotation.publicName != null && annotation.publicName == name),
        orElse: () => Annotation.unset,
      );
}
