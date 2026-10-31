import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/study_task.dart';

class DailyCelebration extends StatefulWidget {
  final List<StudyTask> tasks;

  const DailyCelebration({super.key, required this.tasks});

  @override
  State<DailyCelebration> createState() => _DailyCelebrationState();
}

class _DailyCelebrationState extends State<DailyCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = Tween<double>(
      begin: 0.98,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 900),
    );

    if (_completedAllToday) {
      _controller.forward();
      _confettiController.play();
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<StudyTask> _getTodayTasks(List<StudyTask> tasks) {
    final today = _dateOnly(DateTime.now());

    return tasks.where((task) {
      return _dateOnly(task.studyDate) == today;
    }).toList();
  }

  List<StudyTask> get _todayTasks => _getTodayTasks(widget.tasks);

  bool _areAllTodayTasksCompleted(List<StudyTask> tasks) {
    final todayTasks = _getTodayTasks(tasks);

    return todayTasks.isNotEmpty &&
        todayTasks.every((task) => task.isCompleted);
  }

  bool get _completedAllToday => _areAllTodayTasksCompleted(widget.tasks);

  @override
  void didUpdateWidget(covariant DailyCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasCompleted = _areAllTodayTasksCompleted(oldWidget.tasks);
    final isCompleted = _completedAllToday;

    // Celebrate only when today's tasks change from incomplete to complete.
    if (!wasCompleted && isCompleted) {
      _controller.forward(from: 0);
      _confettiController.play();
    } else if (!isCompleted) {
      _controller.reverse();
      _confettiController.stop();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_completedAllToday) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 22),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.secondary.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: colors.secondary,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You did it!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All your study tasks for today are complete. '
                    'Be proud of the progress you made!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: colors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_todayTasks.length} '
                          '${_todayTasks.length == 1 ? 'task' : 'tasks'} completed',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Confetti overlays the card without blocking user interaction.
        Positioned.fill(
          child: IgnorePointer(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.1,
              numberOfParticles: 10,
              maxBlastForce: 10,
              minBlastForce: 4,
              gravity: 0.2,
              shouldLoop: false,
              colors: [colors.secondary],
            ),
          ),
        ),
      ],
    );
  }
}
