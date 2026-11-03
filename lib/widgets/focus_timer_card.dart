import 'package:flutter/material.dart';

import '../services/focus_timer_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass_surface.dart';

class FocusTimerCard extends StatefulWidget {
  final Duration focusDuration;

  const FocusTimerCard({
    super.key,
    this.focusDuration = const Duration(minutes: 25),
  });

  @override
  State<FocusTimerCard> createState() => _FocusTimerCardState();
}

class _FocusTimerCardState extends State<FocusTimerCard>
    with WidgetsBindingObserver {
  late final FocusTimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FocusTimerController(focusDuration: widget.focusDuration);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _statusLabel(FocusTimerStatus status) {
    return switch (status) {
      FocusTimerStatus.ready => 'Ready when you are',
      FocusTimerStatus.running => 'Focusing',
      FocusTimerStatus.paused => 'Paused',
      FocusTimerStatus.completed => 'Focus session complete',
    };
  }

  String _actionLabel(FocusTimerStatus status) {
    return switch (status) {
      FocusTimerStatus.ready => 'Start focus session',
      FocusTimerStatus.running => 'Pause focus session',
      FocusTimerStatus.paused => 'Resume focus session',
      FocusTimerStatus.completed => 'Start another focus session',
    };
  }

  IconData _actionIcon(FocusTimerStatus status) {
    return status == FocusTimerStatus.running
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final status = _controller.status;
        final isRunning = status == FocusTimerStatus.running;
        final progress =
            (1 -
                    (_controller.remaining.inMilliseconds /
                            widget.focusDuration.inMilliseconds)
                        .clamp(0.0, 1.0))
                .toDouble();

        return GlassSurface(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.card)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkRaised
                          : AppColors.warmSand.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      Icons.center_focus_strong_rounded,
                      color: isDark ? AppColors.warmSand : AppColors.walnut,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus session',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Semantics(
                          liveRegion: true,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Text(
                              _statusLabel(status),
                              key: ValueKey<FocusTimerStatus>(status),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _formatDuration(_controller.remaining),
                        semanticsLabel:
                            'Time remaining ${_formatDuration(_controller.remaining)}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: isDark
                              ? AppColors.darkRaised
                              : AppColors.warmSand.withValues(alpha: 0.4),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.caramel,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: _actionLabel(status),
                      child: FilledButton.icon(
                        onPressed: isRunning
                            ? _controller.pause
                            : _controller.start,
                        icon: Icon(_actionIcon(status)),
                        label: Text(
                          status == FocusTimerStatus.completed
                              ? 'Start again'
                              : status == FocusTimerStatus.paused
                              ? 'Resume'
                              : status == FocusTimerStatus.running
                              ? 'Pause'
                              : 'Start focus',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.walnut,
                          foregroundColor: isDark
                              ? AppColors.warmSand
                              : Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadii.control,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      tooltip: 'Reset focus session',
                      onPressed: _controller.reset,
                      icon: const Icon(Icons.refresh_rounded),
                      color: isDark ? AppColors.warmSand : AppColors.charcoal,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkRaised
                            : AppColors.warmSand.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.control),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
