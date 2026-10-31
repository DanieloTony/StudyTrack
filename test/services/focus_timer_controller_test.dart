import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/services/focus_timer_controller.dart';

void main() {
  late DateTime now;
  late FocusTimerController controller;

  setUp(() {
    now = DateTime(2026, 10, 27, 9);
    controller = FocusTimerController(
      focusDuration: const Duration(minutes: 25),
      now: () => now,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('starts ready with the configured focus duration', () {
    expect(controller.status, FocusTimerStatus.ready);
    expect(controller.remaining, const Duration(minutes: 25));
  });

  test('pause and resume preserve remaining time', () {
    controller.start();
    now = now.add(const Duration(minutes: 5));
    controller.pause();

    expect(controller.status, FocusTimerStatus.paused);
    expect(controller.remaining, const Duration(minutes: 20));

    controller.start();
    expect(controller.status, FocusTimerStatus.running);
    now = now.add(const Duration(minutes: 20));
    controller.refresh();

    expect(controller.status, FocusTimerStatus.completed);
    expect(controller.remaining, Duration.zero);
  });

  test('reset restores the configured duration and ready state', () {
    controller.start();
    now = now.add(const Duration(minutes: 3));
    controller.reset();

    expect(controller.status, FocusTimerStatus.ready);
    expect(controller.remaining, const Duration(minutes: 25));
  });

  test('a completed timer can start a fresh focus session', () {
    controller.start();
    now = now.add(const Duration(minutes: 25));
    controller.refresh();
    controller.start();

    expect(controller.status, FocusTimerStatus.running);
    expect(controller.remaining, const Duration(minutes: 25));
  });
}
