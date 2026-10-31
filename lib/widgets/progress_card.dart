import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const ProgressCard({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final helperTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondaryStrong;
    final progress = total <= 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return Semantics(
      label: total <= 0
          ? 'No study tasks yet'
          : '$completed of $total study tasks completed',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (total > 0)
                  Text(
                    '$completed of $total complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: helperTextColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? AppColors.darkBorder
                      : AppColors.secondaryBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            ] else ...[
              const SizedBox(height: 5),
              Text(
                'Add a task to start tracking your progress.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: helperTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
