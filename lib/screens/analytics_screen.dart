import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_surface.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<StudyTask> tasks;

  const AnalyticsScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final completed = tasks.where((task) => task.isCompleted).length;
    final pending = tasks.length - completed;
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;
    final tasksToHalf = ((tasks.length * 0.5).ceil() - completed)
        .clamp(0, tasks.length);
    final high = tasks.where((task) => task.priority == TaskPriority.high).length;
    final medium = tasks.where((task) => task.priority == TaskPriority.medium).length;
    final low = tasks.where((task) => task.priority == TaskPriority.low).length;
    final upcoming = tasks.where((task) =>
      !task.isCompleted && task.deadline != null &&
      task.deadline!.isAfter(DateTime.now())
    ).toList()..sort((a, b) => a.deadline!.compareTo(b.deadline!));

    final today = DateTime.now();
    final weekStart = DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (index) =>
      weekStart.add(Duration(days: index)));

    return ListView(
      key: const PageStorageKey('analytics-screen'),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 120),
      children: [
        Text('Study Analytics', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text('Understand your learning progress',
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.lg),
        GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: BorderRadius.circular(AppRadii.panel),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.track_changes_rounded, color: AppColors.caramel),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Overall completion', style: theme.textTheme.titleMedium)),
                Text('${(progress * 100).round()}%',
                  style: theme.textTheme.titleMedium?.copyWith(color: AppColors.caramel)),
              ]),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                SizedBox(width: 104, height: 104,
                  child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(
                      value: progress, strokeWidth: 9,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation(AppColors.caramel),
                    ),
                    Text('${(progress * 100).round()}%',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: Column(children: [
                  _MetricRow(label: 'Completed', value: completed, color: AppColors.caramel),
                  const SizedBox(height: AppSpacing.sm),
                  _MetricRow(label: 'Pending', value: pending, color: colors.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.sm),
                  _MetricRow(label: 'Total tasks', value: tasks.length, color: colors.onSurface),
                ])),
              ]),
              const SizedBox(height: AppSpacing.md),
              Text(tasks.isEmpty
                ? 'Add a task to begin tracking progress.'
                : tasksToHalf == 0
                  ? 'You have reached at least 50% completion.'
                  : '$tasksToHalf ${tasksToHalf == 1 ? 'task' : 'tasks'} to reach 50%',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Task priority load', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _PriorityBar(label: 'High', count: high, total: tasks.length, color: AppColors.error),
            const SizedBox(height: AppSpacing.sm),
            _PriorityBar(label: 'Medium', count: medium, total: tasks.length, color: AppColors.caramel),
            const SizedBox(height: AppSpacing.sm),
            _PriorityBar(label: 'Low', count: low, total: tasks.length, color: AppColors.success),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Weekly study cadence', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Tasks scheduled by study date',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.md),
            SizedBox(height: 132, child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final day = days[index];
                final count = tasks.where((task) =>
                  task.studyDate.year == day.year &&
                  task.studyDate.month == day.month &&
                  task.studyDate.day == day.day).length;
                final maxCount = tasks.fold<int>(0, (max, task) {
                  final d = task.studyDate;
                  final sameWeek = !d.isBefore(weekStart) &&
                    d.isBefore(weekStart.add(const Duration(days: 7)));
                  if (!sameWeek) return max;
                  final dayCount = tasks.where((t) =>
                    t.studyDate.year == d.year && t.studyDate.month == d.month &&
                    t.studyDate.day == d.day).length;
                  return dayCount > max ? dayCount : max;
                });
                final barHeight = maxCount == 0 ? 4.0 : 12.0 + 72.0 * count / maxCount;
                const labels = ['M','T','W','T','F','S','S'];
                return Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$count', style: theme.textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Container(height: barHeight, width: 18,
                      decoration: BoxDecoration(
                        color: day.day == today.day && day.month == today.month
                          ? AppColors.caramel : AppColors.caramel.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      )),
                    const SizedBox(height: AppSpacing.xs),
                    Text(labels[index], style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant)),
                  ],
                ));
              }),
            )),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Upcoming deadlines', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (upcoming.isEmpty)
              Text('No upcoming deadlines. You are all caught up.',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant))
            else
              ...upcoming.take(5).map((task) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(children: [
                  const Icon(Icons.event_outlined, size: 18, color: AppColors.caramel),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
                  Text(_deadlineLabel(task.deadline!, today),
                    style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                ]),
              )),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassSurface(
          color: AppColors.darkRaised.withValues(alpha: 0.45),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: const Row(children: [
            Icon(Icons.auto_graph_rounded, color: AppColors.caramel),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('Focus hours, Pomodoro history and study streaks are coming soon. These require persistent focus-session tracking.')),
          ]),
        ),
      ],
    );
  }

  String _deadlineLabel(DateTime deadline, DateTime now) {
    final difference = deadline.difference(now);
    if (difference.inHours < 24) return 'In ${difference.inHours}h';
    return 'In ${difference.inDays}d';
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MetricRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: AppSpacing.sm),
    Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
    Text('$value', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
  ]);
}

class _PriorityBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _PriorityBar({required this.label, required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        Text('$count', style: theme.textTheme.labelLarge),
      ]),
      const SizedBox(height: AppSpacing.xs),
      ClipRRect(borderRadius: BorderRadius.circular(AppRadii.pill),
        child: LinearProgressIndicator(
          value: fraction, minHeight: 8, backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(color),
        )),
    ]);
  }
}
