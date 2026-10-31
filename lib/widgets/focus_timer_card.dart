import 'package:flutter/material.dart';

import '../services/focus_timer_controller.dart';

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

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus session',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _statusLabel(status),
                    key: ValueKey<FocusTimerStatus>(status),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatDuration(_controller.remaining),
                    semanticsLabel:
                        'Time remaining ${_formatDuration(_controller.remaining)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: colors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
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
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.onSurface,
                            foregroundColor: colors.surface,
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      tooltip: 'Reset focus session',
                      onPressed: _controller.reset,
                      icon: const Icon(Icons.refresh_rounded),
                      color: colors.onSurfaceVariant,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surfaceContainerHighest,
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
