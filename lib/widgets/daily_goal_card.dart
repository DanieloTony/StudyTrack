import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass_surface.dart';

class DailyGoalCard extends StatelessWidget {
  final int completed;
  final int total;

  const DailyGoalCard({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasTasks = total > 0;
    final progress = hasTasks
        ? (completed / total).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final percent = (progress * 100).round();

    final semanticsLabel = hasTasks
        ? 'Daily goal: $completed of $total tasks completed, $percent percent'
        : 'Daily goal: no study tasks scheduled today';

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: GlassSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.card)),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark
                            ? AppColors.darkRaised
                            : AppColors.warmSand.withValues(alpha: 0.45),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.caramel,
                        ),
                      ),
                      Center(
                        child: Text(
                          hasTasks ? '$percent%' : '—',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily goal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    hasTasks
                        ? '$completed of $total ${total == 1 ? 'task' : 'tasks'} completed today'
                        : 'No study tasks scheduled today.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  if (hasTasks) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      completed == total
                          ? 'Daily target complete'
                          : '${total - completed} '
                                '${total - completed == 1 ? 'task' : 'tasks'} '
                                'to go',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.caramel : AppColors.walnut,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
