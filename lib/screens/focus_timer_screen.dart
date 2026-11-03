import 'package:flutter/material.dart';

import '../services/focus_timer_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_surface.dart';

class FocusTimerScreen extends StatelessWidget {
  final FocusTimerController controller;

  const FocusTimerScreen({super.key, required this.controller});

  String _format(Duration duration) {
    final seconds = duration.inSeconds;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(seconds % 60).toString().padLeft(2, '0')}';
  }

  String _status(FocusTimerStatus status) => switch (status) {
    FocusTimerStatus.ready => 'Ready to begin',
    FocusTimerStatus.running => 'Stay present. You are focusing.',
    FocusTimerStatus.paused => 'Your session is paused',
    FocusTimerStatus.completed => 'Focus session complete',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      key: const PageStorageKey('focus-timer-screen'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.lg, AppSpacing.md, 120,
      ),
      children: [
        Text('Focus Session', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text('Stay present and build your momentum.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            )),
        const SizedBox(height: AppSpacing.lg),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final status = controller.status;
            final progress = (1 -
              controller.remaining.inMilliseconds /
              controller.focusDuration.inMilliseconds).clamp(0.0, 1.0);
            final actionLabel = switch (status) {
              FocusTimerStatus.ready => 'Start Focus',
              FocusTimerStatus.running => 'Pause Session',
              FocusTimerStatus.paused => 'Resume Focus',
              FocusTimerStatus.completed => 'Start Again',
            };
            return GlassSurface(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: BorderRadius.circular(AppRadii.panel),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.spa_rounded, color: AppColors.caramel),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text('POMODORO • 25 MIN',
                        style: theme.textTheme.labelLarge)),
                      _StatusPill(label: status.name.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: 244,
                    height: 244,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 224,
                          height: 224,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.caramel.withValues(alpha: 0.12),
                                blurRadius: 34,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 218,
                          height: 218,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress.toDouble()),
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) =>
                              CircularProgressIndicator(
                                value: value,
                                strokeWidth: 9,
                                strokeCap: StrokeCap.round,
                                backgroundColor: colors.surfaceContainerHighest,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.caramel,
                                ),
                              ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('DEEP WORK',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.caramel,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w800,
                              )),
                            const SizedBox(height: AppSpacing.xs),
                            Text(_format(controller.remaining),
                              semanticsLabel: 'Time remaining ${_format(controller.remaining)}',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              )),
                            const SizedBox(height: AppSpacing.xs),
                            Text(_status(status),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: status == FocusTimerStatus.running
                            ? controller.pause : controller.start,
                          icon: Icon(status == FocusTimerStatus.running
                            ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          label: Text(actionLabel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        height: 48, width: 52,
                        child: OutlinedButton(
                          onPressed: controller.reset,
                          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Icon(Icons.refresh_rounded),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.caramel),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Focus duration',
                style: theme.textTheme.titleSmall)),
              Text('25 minutes', style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
              )),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.caramel),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(
                'Give one meaningful task your full attention. Small, focused steps build lasting progress.',
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    decoration: BoxDecoration(
      color: AppColors.caramel.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: Border.all(color: AppColors.caramel.withValues(alpha: 0.35)),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.caramel, fontWeight: FontWeight.w800,
    )),
  );
}
