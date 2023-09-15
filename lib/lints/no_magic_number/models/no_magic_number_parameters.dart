/// A data model class that represents the "no magic numbers" input
/// parameters.
class NoMagicNumberParameters {
  static const _allowedConfigName = 'allowed';
  static const _defaultMagicNumbers = [-1, 0, 1];

  /// List of allowed numbers
  final Iterable<num> allowedNumbers;

  /// Constructor for [NoMagicNumberParameters] model
  const NoMagicNumberParameters({
    required this.allowedNumbers,
  });

  /// Method for creating from json data
  factory NoMagicNumberParameters.fromJson(Map<String, Object?> json) =>
      NoMagicNumberParameters(
        allowedNumbers:
            json[_allowedConfigName] as Iterable<num>? ?? _defaultMagicNumbers,
      );
}
