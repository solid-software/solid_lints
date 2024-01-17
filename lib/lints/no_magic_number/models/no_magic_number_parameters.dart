/// A data model class that represents the "no magic numbers" input
/// parameters.
class NoMagicNumberParameters {
  static const _allowedConfigName = 'allowed';
  static const _allowedInWidgetParamsConfigName = 'allowed_in_widget_params';
  static const _defaultMagicNumbers = [-1, 0, 1];

  /// List of numbers excluded from analysis
  ///
  /// Defaults to numbers commonly used for increments and index access:
  /// `[-1, 0, 1]`.
  final Iterable<num> allowedNumbers;

  /// Boolean flag, toggles analysis for raw numbers within Widget constructor
  /// call parameters.
  ///
  /// When flag is set to `false`, it warns about any non-const numbers in
  /// your layout:
  ///
  /// ```dart
  /// Widget build() {
  ///   return MyWidget(
  ///     decoration: MyWidgetDecoration(size: 12), // LINT
  ///     value: 23,                                // LINT
  ///     child: const SizedBox(width: 20)          // allowed for const
  ///   );
  /// }
  /// ```
  ///
  /// When flag is set to `true`, it allows non-const layouts with raw numbers:
  ///
  /// ```dart
  /// Widget build() {
  ///   return MyWidget(
  ///     decoration: MyWidgetDecoration(size: 12), // OK
  ///     value: 23, // OK
  ///     child: const SizedBox(width: 20) // OK as it was
  ///   );
  /// }
  /// ```
  ///
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
