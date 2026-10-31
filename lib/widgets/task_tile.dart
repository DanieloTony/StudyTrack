import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_colors.dart';

class TaskTile extends StatefulWidget {
  final StudyTask task;
  final ValueChanged<StudyTask> onToggle;
  final ValueChanged<StudyTask>? onEdit;
  final ValueChanged<StudyTask>? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _completionController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.045,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.045,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
    ]).animate(_completionController);
  }

  @override
  void didUpdateWidget(covariant TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.task.isCompleted && widget.task.isCompleted) {
      _completionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _completionController.dispose();
    super.dispose();
  }

  Color _priorityColor(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    switch (widget.task.priority) {
      case TaskPriority.high:
        return colors.error;
      case TaskPriority.medium:
        return theme.brightness == Brightness.dark
            ? AppColors.darkWarning
            : AppColors.warning;
      case TaskPriority.low:
        return theme.brightness == Brightness.dark
            ? AppColors.darkSuccess
            : AppColors.success;
    }
  }

  String _priorityLabel() {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  bool get _isOverdue {
    return !widget.task.isCompleted &&
        widget.task.deadline != null &&
        widget.task.deadline!.isBefore(DateTime.now());
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) return 'Today';
    if (selected == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    }

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = _priorityColor(context);
    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? successColor.withValues(alpha: isDark ? 0.10 : 0.06)
              : colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isOverdue
                ? colors.error.withValues(alpha: 0.6)
                : task.isCompleted
                ? successColor.withValues(alpha: 0.45)
                : isDark
                ? AppColors.darkBorder
                : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _AnimatedTaskCheckbox(
                isCompleted: task.isCompleted,
                onTap: () => widget.onToggle(task),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 7),

                  // Smoothly animates text color and strike-through.
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: successColor,
                      decorationThickness: 2,
                      color: task.isCompleted
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                    ),
                    child: Text(task.title),
                  ),

                  if (task.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: task.isCompleted ? 0.65 : 1.0,
                      child: Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _Tag(
                        icon: Icons.calendar_today_outlined,
                        label: _dateLabel(task.studyDate),
                      ),
                      _Tag(
                        icon: Icons.flag_outlined,
                        label: _priorityLabel(),
                        color: priorityColor,
                      ),
                      if (task.deadline != null)
                        _Tag(
                          icon: _isOverdue
                              ? Icons.warning_amber_rounded
                              : Icons.schedule_rounded,
                          label: _isOverdue
                              ? 'Overdue'
                              : 'Due ${TimeOfDay.fromDateTime(task.deadline!).format(context)}',
                          color: _isOverdue
                              ? colors.error
                              : colors.onSurfaceVariant,
                        ),

                      // Completion badge enters and exits smoothly.
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: task.isCompleted
                            ? _Tag(
                                key: ValueKey('completed'),
                                icon: Icons.check_circle_rounded,
                                label: 'Completed',
                                color: successColor,
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('not-completed'),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            PopupMenuButton<String>(
              tooltip: 'Task actions',
              onSelected: (value) {
                if (value == 'edit') widget.onEdit?.call(task);
                if (value == 'delete') widget.onDelete?.call(task);
              },
              itemBuilder: (context) => [
                if (widget.onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit task'),
                    ),
                  ),
                if (widget.onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.error,
                      ),
                      title: Text('Delete task'),
                    ),
                  ),
              ],
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;

  const _AnimatedTaskCheckbox({required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      checked: isCompleted,
      label: isCompleted ? 'Mark task incomplete' : 'Complete task',
      child: Tooltip(
        message: isCompleted ? 'Mark incomplete' : 'Complete task',
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? colors.primary : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? colors.primary
                    : colors.onSurfaceVariant.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey('checked'),
                      color: colors.onPrimary,
                      size: 19,
                    )
                  : const SizedBox(
                      key: ValueKey('unchecked'),
                      width: 19,
                      height: 19,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const _Tag({super.key, required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: effectiveColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
