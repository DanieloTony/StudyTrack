import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/daily_celebration.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/focus_timer_card.dart';
import '../widgets/glass_surface.dart';
import '../widgets/progress_card.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  final List<StudyTask> tasks;
  final bool isLoading;
  final bool hasLoadError;
  final VoidCallback onRetryLoad;
  final VoidCallback? onAddTask;
  final VoidCallback onShowTasks;
  final ValueChanged<StudyTask> onToggleTask;
  final ValueChanged<StudyTask> onEditTask;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.hasLoadError,
    required this.onRetryLoad,
    this.onAddTask,
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
    final now = DateTime.now();
    final today = _dateOnly(now);
    final todayTasks = tasks.where((task) {
      return _dateOnly(task.studyDate) == today;
    }).toList()..sort(_compareTasks);
    final pendingToday = todayTasks.where((task) => !task.isCompleted).toList();
    final completedToday = todayTasks.where((task) => task.isCompleted).length;
    final completedAll = tasks.where((task) => task.isCompleted).length;

    // Upcoming deadlines: non-completed tasks scheduled for after today or with future deadlines
    final upcomingTasks = tasks.where((task) {
      if (task.isCompleted) return false;
      final taskDate = _dateOnly(task.studyDate);
      if (taskDate.isAfter(today)) return true;
      if (task.deadline != null && task.deadline!.isAfter(now)) {
        return taskDate != today;
      }
      return false;
    }).toList()..sort((a, b) {
      final aDate = a.deadline ?? a.studyDate;
      final bDate = b.deadline ?? b.studyDate;
      return aDate.compareTo(bDate);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 28.0;
        final contentWidth = constraints.maxWidth < 760
            ? constraints.maxWidth
            : 760.0;

        return Center(
          child: SizedBox(
            width: contentWidth,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.md,
                horizontalPadding,
                216,
              ),
              children: [
                // 1. Greeting Section with Profile & Date
                _StudyHomeHeader(
                  greeting: '${_greeting()}, Maya',
                  subtitle: 'Make today count · Semester in progress',
                  date: _formattedDate(now),
                ),
                const SizedBox(height: AppSpacing.md),

                // 2. Daily Goal & Progress Card
                if (isLoading)
                  const _LoadingState()
                else if (hasLoadError)
                  _LoadErrorState(onRetry: onRetryLoad)
                else
                  DailyGoalCard(
                    completed: completedToday,
                    total: todayTasks.length,
                  ),
                const SizedBox(height: AppSpacing.sm),

                // 3. Focus Timer Card
                const FocusTimerCard(),
                const SizedBox(height: AppSpacing.md),

                // Study Tracks Advisory / Context
                _SectionHeading(
                  title: 'Your study tracks',
                  detail: 'Subject hours are not tracked yet',
                ),
                const SizedBox(height: AppSpacing.xs),
                const _StudyTracksUnavailable(),
                const SizedBox(height: AppSpacing.md),

                // 4. Today's Tasks
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
                  const SizedBox(height: AppSpacing.xs),
                  if (todayTasks.isNotEmpty && pendingToday.isEmpty)
                    DailyCelebration(tasks: tasks)
                  else if (todayTasks.isEmpty)
                    _TodayTaskMessage(
                      title: 'No sessions planned today',
                      message: 'Add a study task whenever you are ready.',
                      icon: Icons.event_note_outlined,
                      onAddTask: onAddTask,
                    )
                  else ...[
                    ...todayTasks.take(4).map((task) {
                      return TaskTile(
                        key: ValueKey(task.id),
                        task: task,
                        onToggle: (_) => onToggleTask(task),
                        onEdit: (_) => onEditTask(task),
                      );
                    }),
                    if (todayTasks.length > 4)
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: onShowTasks,
                          child: Text(
                            'View ${todayTasks.length - 4} more tasks',
                          ),
                        ),
                      ),
                  ],
                ],

                // 5. Upcoming Deadlines Section
                if (upcomingTasks.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _SectionHeading(
                    title: 'Upcoming deadlines',
                    detail: '${upcomingTasks.length} upcoming milestones',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...upcomingTasks.take(3).map((task) {
                    return _UpcomingDeadlineCard(
                      task: task,
                      onTap: () => onEditTask(task),
                    );
                  }),
                ],

                // 6. Overall Progress Section
                const SizedBox(height: AppSpacing.md),
                _SectionHeading(
                  title: 'Cumulative Progress',
                  detail: 'Semester task completion overview',
                ),
                const SizedBox(height: AppSpacing.xs),
                ProgressCard(
                  completed: completedAll,
                  total: tasks.length,
                ),
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
    final isDark = theme.brightness == Brightness.dark;

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
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Semantics(
              label: 'Study streak tracking is not available',
              child: GlassSurface(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.control),
                ),
                showShadow: false,
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
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: isDark ? AppColors.caramel : AppColors.walnut,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
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

class _UpcomingDeadlineCard extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onTap;

  const _UpcomingDeadlineCard({required this.task, required this.onTap});

  String _formatDeadline(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);

    if (taskDay == today) return 'Today';
    if (taskDay == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final date = task.deadline ?? task.studyDate;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: BorderRadius.circular(AppRadii.compact),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.compact),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkRaised
                      : AppColors.warmSand.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
                child: Icon(
                  Icons.event_outlined,
                  size: 18,
                  color: isDark ? AppColors.warmSand : AppColors.walnut,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Due ${_formatDeadline(date)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.caramel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.caramel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyTracksUnavailable extends StatelessWidget {
  const _StudyTracksUnavailable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GlassSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.compact)),
      showShadow: false,
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
  final VoidCallback? onAddTask;

  const _TodayTaskMessage({
    required this.title,
    required this.message,
    required this.icon,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.card)),
      showShadow: false,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkRaised
                  : AppColors.warmSand.withValues(alpha: 0.35),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.caramel : AppColors.walnut,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (onAddTask != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Plan today\'s first task'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.walnut,
                foregroundColor: isDark ? AppColors.warmSand : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
              ),
            ),
          ],
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

    return GlassSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.compact)),
      showShadow: false,
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
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

    return GlassSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.compact)),
      showShadow: false,
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
          const SizedBox(height: AppSpacing.xs),
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
