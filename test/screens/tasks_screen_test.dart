import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/screens/tasks_screen.dart';
import 'package:studytrack/theme/app_theme.dart';

void main() {
  testWidgets('task search and status filters preserve matching behavior', (
    tester,
  ) async {
    final today = DateTime.now();
    final tasks = [
      StudyTask(
        id: 'pending-graph',
        title: 'Review graph theory',
        description: 'Study traversal algorithms',
        studyDate: today,
      ),
      StudyTask(
        id: 'completed-proof',
        title: 'Proof exercises',
        studyDate: today,
        isCompleted: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TasksScreen(
            tasks: tasks,
            isLoading: false,
            onAddTask: () {},
            onToggleTask: (_) {},
            onDeleteTask: (_) async => true,
            onEditTask: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'graph');
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('1 task found'), findsOneWidget);
    expect(find.text('Review graph theory'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('No matching tasks'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('1 task found'), findsOneWidget);
    expect(find.text('Proof exercises'), findsOneWidget);
  });

  testWidgets('task screen controls fit a compact phone width', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: TasksScreen(
            tasks: const [],
            isLoading: false,
            onAddTask: () {},
            onToggleTask: (_) {},
            onDeleteTask: (_) async => true,
            onEditTask: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SegmentedButton<TaskFilter>), findsOneWidget);
  });

  testWidgets('last task clears the floating action area', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tasks = List.generate(
      12,
      (index) => StudyTask(
        id: 'task-$index',
        title: 'Task $index',
        studyDate: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TasksScreen(
            tasks: tasks,
            isLoading: false,
            onAddTask: () {},
            onToggleTask: (_) {},
            onDeleteTask: (_) async => true,
            onEditTask: (_) {},
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: const Text('New task'),
          ),
          bottomNavigationBar: const SizedBox(height: 76),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('12 tasks found'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Task 0'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Task 0'), findsOneWidget);
    expect(
      tester.getRect(find.text('Task 0')).bottom,
      lessThan(tester.getRect(find.byType(FloatingActionButton)).top),
    );
    expect(tester.takeException(), isNull);
  });
}
