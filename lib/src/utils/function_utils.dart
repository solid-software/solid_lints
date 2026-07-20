/// Utility functions.
abstract final class FunctionUtils {
  /// Executes the [f], returning its result or `null` if any
  /// exception/error is thrown.
  static T? tryOrNull<T>(T Function() f) {
    try {
      return f();
    } catch (_) {
      return null;
    }
  }
}
