import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass_surface.dart';

class ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const ProgressCard({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final progress = total <= 0
        ? 0.0
        : (completed / total).clamp(0.0, 1.0).toDouble();

    return Semantics(
      label: total <= 0
          ? 'No study tasks yet'
          : '$completed of $total study tasks completed',
      child: GlassSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.compact)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'All study tasks',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (total > 0)
                  Text(
                    '$completed of $total complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? AppColors.darkRaised
                          : AppColors.warmSand.withValues(alpha: 0.4),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.caramel,
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add a task to start tracking your progress.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
