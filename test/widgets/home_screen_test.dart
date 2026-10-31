import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/screens/home_screen.dart';
import 'package:studytrack/theme/app_theme.dart';
import 'package:studytrack/widgets/daily_goal_card.dart';
import 'package:studytrack/widgets/focus_timer_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily goal shows an honest empty state with no tasks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: DailyGoalCard(completed: 0, total: 0)),
      ),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.text('No study tasks scheduled today.'), findsOneWidget);
  });

  testWidgets('daily goal derives its progress from task completion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: DailyGoalCard(completed: 1, total: 2)),
      ),
    );

    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1 of 2 tasks completed today'), findsOneWidget);
  });

  testWidgets('focus timer exposes start, pause, resume, and reset controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: FocusTimerCard()),
      ),
    );

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);

    await tester.tap(find.text('Start focus'));
    await tester.pump();
    expect(find.text('Focusing'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(find.text('Focusing'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset focus session'));
    await tester.pump();
    expect(find.text('Ready when you are'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('home uses existing tasks and does not invent study tracks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final task = StudyTask(
      id: 'real-task',
      title: 'Review algorithms',
      studyDate: DateTime(now.year, now.month, now.day),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: HomeScreen(
            tasks: [task],
            isLoading: false,
            hasLoadError: false,
            onRetryLoad: () {},
            onAddTask: () {},
            onShowTasks: () {},
            onToggleTask: (_) {},
            onEditTask: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Streaks untracked'), findsOneWidget);
    expect(
      find.text(
        'Tasks track dates and completion, but not subjects or study hours.',
      ),
      findsOneWidget,
    );
    expect(find.text('0 of 1 task completed today'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Review algorithms'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Review algorithms'), findsOneWidget);
  });
}
