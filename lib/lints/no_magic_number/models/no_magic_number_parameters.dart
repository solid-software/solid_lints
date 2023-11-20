/// A data model class that represents the "no magic numbers" input
/// parameters.
class NoMagicNumberParameters {
  static const _allowedConfigName = 'allowed';
  static const _allowedInWidgetParamsConfigName = 'allowed_in_widget_params';
  static const _defaultMagicNumbers = [-1, 0, 1];

  /// List of allowed numbers
  final Iterable<num> allowedNumbers;

  /// The flag indicates whether magic numbers are allowed as a Widget instance
  /// parameter.
  final bool allowedInWidgetParams;

  /// Constructor for [NoMagicNumberParameters] model
  const NoMagicNumberParameters({
    required this.allowedNumbers,
    required this.allowedInWidgetParams,
  });

  /// Method for creating from json data
  factory NoMagicNumberParameters.fromJson(Map<String, Object?> json) =>
      NoMagicNumberParameters(
        allowedNumbers:
            json[_allowedConfigName] as Iterable<num>? ?? _defaultMagicNumbers,
        allowedInWidgetParams:
            json[_allowedInWidgetParamsConfigName] as bool? ?? false,
      );
}
