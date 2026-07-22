import 'dart:async';

/// A utility class for debouncing quick, successive operations.
///
/// It guarantees that an action is executed only once after a specified [delay]
/// of inactivity, cancelling any previously scheduled execution if a new one is
/// requested before the delay completes.
class Debouncer {
  /// The duration to wait before executing the action.
  final Duration delay;
  Timer? _timer;

  /// Creates a new [Debouncer] with the given [delay].
  Debouncer(this.delay);

  /// Schedules [action] to be executed after the configured [delay].
  ///
  /// If [run] is called again before the delay expires, the previous timer
  /// is cancelled and a new one is started.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any scheduled action from executing.
  void cancel() {
    _timer?.cancel();
  }
}
