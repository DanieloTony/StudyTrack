import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/screens/home_screen.dart';
import 'package:studytrack/theme/app_colors.dart';
import 'package:studytrack/theme/app_theme.dart';
import 'package:studytrack/widgets/daily_goal_card.dart';
import 'package:studytrack/widgets/focus_timer_card.dart';
import 'package:studytrack/widgets/glass_surface.dart';

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

  testWidgets('empty state triggers task planning action', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var addTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HomeScreen(
            tasks: const [],
            isLoading: false,
            hasLoadError: false,
            onRetryLoad: () {},
            onAddTask: () => addTriggered = true,
            onShowTasks: () {},
            onToggleTask: (_) {},
            onEditTask: (_) {},
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Plan today\'s first task'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('No sessions planned today'), findsOneWidget);
    expect(find.text('Add a study task whenever you are ready.'), findsOneWidget);
    expect(find.text('Plan today\'s first task'), findsOneWidget);

    await tester.tap(find.text('Plan today\'s first task'));
    await tester.pump();
    expect(addTriggered, isTrue);
  });

  testWidgets('home screen renders without overflow across diverse Android viewport sizes and themes', (
    tester,
  ) async {
    final sizes = [
      const Size(360, 640), // Compact Android phone
      const Size(390, 844), // Standard Android phone
      const Size(412, 915), // Large Android phone
    ];

    final now = DateTime.now();
    final tasks = [
      StudyTask(
        id: 't-today-1',
        title: 'Organic Chemistry Lab',
        studyDate: DateTime(now.year, now.month, now.day),
        deadline: DateTime(now.year, now.month, now.day, 14, 0),
        priority: TaskPriority.high,
      ),
      StudyTask(
        id: 't-today-2',
        title: 'Macroeconomics Case Study',
        studyDate: DateTime(now.year, now.month, now.day),
        priority: TaskPriority.medium,
        isCompleted: true,
      ),
      StudyTask(
        id: 't-upcoming-1',
        title: 'Linear Algebra Final Review',
        studyDate: now.add(const Duration(days: 2)),
        priority: TaskPriority.high,
      ),
    ];

    for (final size in sizes) {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: HomeScreen(
                tasks: tasks,
                isLoading: false,
                hasLoadError: false,
                onRetryLoad: () {},
                onAddTask: () {},
                onShowTasks: () {},
                onToggleTask: (_) {},
                onEditTask: (_) {},
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: AppColors.walnut,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Plan a study task'),
              ),
              bottomNavigationBar: SafeArea(
                child: GlassSurface(
                  key: const ValueKey('main-navigation'),
                  child: const SizedBox(height: 56),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Streaks untracked'), findsOneWidget);
        expect(find.text('1 of 2 tasks completed today'), findsOneWidget);
      }
    }
  });
}
