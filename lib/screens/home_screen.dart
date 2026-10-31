import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../widgets/daily_celebration.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/focus_timer_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  final List<StudyTask> tasks;
  final bool isLoading;
  final bool hasLoadError;
  final VoidCallback onRetryLoad;
  final VoidCallback onAddTask;
  final VoidCallback onShowTasks;
  final ValueChanged<StudyTask> onToggleTask;
  final ValueChanged<StudyTask> onEditTask;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.hasLoadError,
    required this.onRetryLoad,
    required this.onAddTask,
    required this.onShowTasks,
    required this.onToggleTask,
    required this.onEditTask,
  });

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  int _compareTasks(StudyTask a, StudyTask b) {
    if (a.deadline == null && b.deadline == null) {
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
    if (a.deadline == null) return 1;
    if (b.deadline == null) return -1;
    return a.deadline!.compareTo(b.deadline!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();
    final today = _dateOnly(now);
    final todayTasks = tasks.where((task) {
      return _dateOnly(task.studyDate) == today;
    }).toList()..sort(_compareTasks);
    final pendingToday = todayTasks.where((task) => !task.isCompleted).toList();
    final completedToday = todayTasks.where((task) => task.isCompleted).length;
    final completedAll = tasks.where((task) => task.isCompleted).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 600 ? 20.0 : 32.0;
        final contentWidth = constraints.maxWidth < 760
            ? constraints.maxWidth
            : 760.0;

        return Center(
          child: SizedBox(
            width: contentWidth,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                28,
              ),
              children: [
                _StudyHomeHeader(
                  greeting: _greeting(),
                  subtitle: 'Make today count.',
                  date: _formattedDate(now),
                ),
                const SizedBox(height: 22),
                if (isLoading)
                  const _LoadingState()
                else if (hasLoadError)
                  _LoadErrorState(onRetry: onRetryLoad)
                else
                  DailyGoalCard(
                    completed: completedToday,
                    total: todayTasks.length,
                  ),
                const SizedBox(height: 16),
                const FocusTimerCard(),
                const SizedBox(height: 26),
                _SectionHeading(
                  title: 'Your study tracks',
                  detail: 'Subject hours are not tracked yet',
                ),
                const SizedBox(height: 12),
                const _StudyTracksUnavailable(),
                const SizedBox(height: 26),
                _SectionHeading(
                  title: "Today's tasks",
                  detail: isLoading || hasLoadError
                      ? 'Your study plan'
                      : pendingToday.isEmpty
                      ? 'A little progress at a time'
                      : '${pendingToday.length} '
                            '${pendingToday.length == 1 ? 'task' : 'tasks'} '
                            'left to focus on',
                  action: TextButton(
                    onPressed: onShowTasks,
                    child: const Text('See all'),
                  ),
                ),
                if (!isLoading && !hasLoadError) ...[
                  const SizedBox(height: 12),
                  if (todayTasks.isNotEmpty && pendingToday.isEmpty)
                    DailyCelebration(tasks: tasks)
                  else if (todayTasks.isEmpty)
                    const _TodayTaskMessage(
                      title: 'No sessions planned today',
                      message: 'Add a study task whenever you are ready.',
                      icon: Icons.event_note_outlined,
                    )
                  else ...[
                    ...pendingToday.take(4).map((task) {
                      return TaskTile(
                        key: ValueKey(task.id),
                        task: task,
                        onToggle: (_) => onToggleTask(task),
                        onEdit: (_) => onEditTask(task),
                      );
                    }),
                    if (pendingToday.length > 4)
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: onShowTasks,
                          child: Text(
                            'View ${pendingToday.length - 4} more tasks',
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAddTask,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Plan a study task'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        minimumSize: const Size.fromHeight(48),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProgressCard(completed: completedAll, total: tasks.length),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudyHomeHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final String date;

  const _StudyHomeHeader({
    required this.greeting,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Study streak tracking is not available',
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Streaks untracked',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          date,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String detail;
  final Widget? action;

  const _SectionHeading({
    required this.title,
    required this.detail,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}

class _StudyTracksUnavailable extends StatelessWidget {
  const _StudyTracksUnavailable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Tasks track dates and completion, but not subjects or study hours.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
          height: 1.45,
        ),
      ),
    );
  }
}

class _TodayTaskMessage extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _TodayTaskMessage({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading today’s plan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Couldn't load saved tasks",
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your stored data has not been cleared. Try loading it again.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
