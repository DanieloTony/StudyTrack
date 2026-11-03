import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_surface.dart';

class SettingsScreen extends StatelessWidget {
  final List<StudyTask> tasks;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.tasks,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final pending = tasks.length - completed;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth < 800
            ? constraints.maxWidth
            : 800.0;
        final horizontalPadding = constraints.maxWidth < 600
            ? AppSpacing.md
            : AppSpacing.xl;

        return Center(
          child: SizedBox(
            width: contentWidth,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.lg,
                horizontalPadding,
                112,
              ),
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Make StudyTrack work for you.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassSurface(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.panel),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.2
                                : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.compact),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: colors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'StudyTrack',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Build better habits, one day at a time.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SettingsSectionHeading(
                  title: 'Your activity',
                  subtitle: 'A snapshot of your study tasks',
                ),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, rowConstraints) {
                    final gap = AppSpacing.sm;
                    final cardWidth = (rowConstraints.maxWidth - gap * 2) / 3;

                    return Row(
                      children: [
                        Expanded(
                          child: _ActivityCard(
                            label: 'Created',
                            count: tasks.length,
                            icon: Icons.checklist_rounded,
                            width: cardWidth,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _ActivityCard(
                            label: 'Completed',
                            count: completed,
                            icon: Icons.task_alt_rounded,
                            width: cardWidth,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _ActivityCard(
                            label: 'Pending',
                            count: pending,
                            icon: Icons.pending_actions_rounded,
                            width: cardWidth,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SettingsSectionHeading(
                  title: 'Appearance',
                  subtitle: 'Choose a comfortable look for StudyTrack',
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassSurface(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.card),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    clipBehavior: Clip.antiAlias,
                    child: SwitchListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.control),
                      ),
                      value: isDarkMode,
                      onChanged: onThemeChanged,
                      activeThumbColor: colors.primary,
                      secondary: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.2
                                : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.control),
                        ),
                        child: Icon(
                          isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: colors.primary,
                        ),
                      ),
                      title: Text(
                        isDarkMode ? 'Dark appearance' : 'Light appearance',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Switch between light and dark themes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassSurface(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.card),
                  ),
                  showShadow: false,
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_outline_rounded,
                        color: colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keep growing',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Consistency matters more than perfection.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text(
                    'StudyTrack • Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SettingsSectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final double width;

  const _ActivityCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: width,
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.compact)),
        showShadow: false,
        child: Column(
          children: [
            Icon(icon, color: colors.primary, size: 21),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$count',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
