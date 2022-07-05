import 'dart:async';
import '/app/env.dart';

typedef MaybeCallback = void Function(String);

// callbacks are of the form void myFunc(String id), where id is the key to cancel
// all future occurrences via Maybe.cancel(id)

class Maybe {
  // repeatable, cancellable futures.  all times given in ms

  // delay ms then call once, if ms not specified, schedule for immediate async
  // execution.  can cancel with string provided to callback
  factory Maybe.delay(MaybeCallback f, {int? ms, String? id}) => Maybe(f, delay: ms, id: id);

  // delay ms then repeat (delay is initial, interval is ms between invocations)
  // not specifying delay will schedule immediate async execution and then repeat
  // at interval.  can cancel with string provided to callback.
  factory Maybe.repeat(MaybeCallback f, {int? delay, int? interval, String? id}) =>
      Maybe(f, delay: delay, interval: interval, id: id);

  static void cancel(String id) {
    if (_tasks[id]?._timer != null && _tasks[id]!._timer!.isActive) {
      _tasks[id]!._timer!.cancel();
      _tasks.remove(id);
    }
    _cleanup();
  }

  static void shutdown() {
    for (Maybe m in _tasks.values) {
      m._timer?.cancel();
    }
    _tasks.clear();
  }

  static void suspend() {} // TODO
  static void resume() {}

  // implementation
  static final Map<String, Maybe> _tasks = {};

  late final String id;
  late final int delay; // all times in millis
  late final int interval; // all times in millis
  final MaybeCallback callback;
  Timer? _timer;

  Maybe(this.callback, {int? delay, String? id, int? interval}) {
    this.id = id ?? env.randomString();
    this.delay = delay ?? 0;
    this.interval = interval ?? 0;
    if (this.interval == 0) {
      _timer = Timer(Duration(milliseconds: this.delay), () => callback(this.id));
    } else {
      Timer repeater =
          Timer.periodic(Duration(milliseconds: this.interval), (_) => callback(this.id));
      if (this.delay != this.interval) {
        _timer = Timer(Duration(milliseconds: this.delay), () {
          callback(this.id);
          _timer = repeater;
        });
      } else {
        _timer = Timer(Duration(milliseconds: this.delay), () {
          callback(this.id);
          _timer = Timer.periodic(Duration(milliseconds: this.interval), (_) => callback(this.id));
        });
      }
    }
    _cleanup();
    _tasks[this.id] = this;
  }

  static void _cleanup() {
    final removals = [];
    for (MapEntry e in _tasks.entries) {
      if (e.value._timer == null || !e.value.timer._timer.isActive) {
        removals.add(e.key);
      }
    }
    removals.forEach(_tasks.remove);
  }
}
