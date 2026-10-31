import 'dart:async';

import 'package:flutter/foundation.dart';

enum FocusTimerStatus { ready, running, paused, completed }

class FocusTimerController extends ChangeNotifier {
  final Duration focusDuration;
  final DateTime Function() _now;

  Timer? _ticker;
  DateTime? _deadline;
  late Duration _remaining;
  FocusTimerStatus _status = FocusTimerStatus.ready;

  FocusTimerController({
    this.focusDuration = const Duration(minutes: 25),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    if (focusDuration <= Duration.zero) {
      throw ArgumentError.value(
        focusDuration,
        'focusDuration',
        'Must be greater than zero.',
      );
    }

    _remaining = focusDuration;
  }

  Duration get remaining => _remaining;
  FocusTimerStatus get status => _status;

  void start() {
    if (_status == FocusTimerStatus.running) return;

    if (_status == FocusTimerStatus.completed) {
      _remaining = focusDuration;
    }

    _deadline = _now().add(_remaining);
    _status = FocusTimerStatus.running;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
    notifyListeners();
  }

  void pause() {
    if (_status != FocusTimerStatus.running) return;

    final remaining = _deadline!.difference(_now());
    _ticker?.cancel();
    _ticker = null;
    _deadline = null;

    if (remaining <= Duration.zero) {
      _remaining = Duration.zero;
      _status = FocusTimerStatus.completed;
    } else {
      _remaining = remaining;
      _status = FocusTimerStatus.paused;
    }

    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _deadline = null;
    _remaining = focusDuration;
    _status = FocusTimerStatus.ready;
    notifyListeners();
  }

  void refresh() {
    if (_status != FocusTimerStatus.running) return;

    final remaining = _deadline!.difference(_now());
    if (remaining <= Duration.zero) {
      _remaining = Duration.zero;
      _status = FocusTimerStatus.completed;
      _deadline = null;
      _ticker?.cancel();
      _ticker = null;
    } else {
      _remaining = remaining;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
