import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass_surface.dart';

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
          end: 1.035,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.035,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.task.priority) {
      case TaskPriority.high:
        return AppColors.caramel;
      case TaskPriority.medium:
        return isDark ? AppColors.warmSand : AppColors.walnut;
      case TaskPriority.low:
        return isDark ? AppColors.darkMeta : AppColors.charcoal;
    }
  }

  IconData _priorityIcon() {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.low:
        return Icons.keyboard_double_arrow_down_rounded;
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
    final completionColor = isDark ? AppColors.caramel : AppColors.walnut;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.compact)),
          color: task.isCompleted
              ? (isDark
                  ? AppColors.darkRaised.withValues(alpha: 0.5)
                  : AppColors.warmSand.withValues(alpha: 0.18))
              : null,
          borderColor: _isOverdue
              ? colors.error.withValues(alpha: isDark ? 0.72 : 0.55)
              : task.isCompleted
              ? completionColor.withValues(alpha: 0.35)
              : null,
          showShadow: !task.isCompleted,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: _AnimatedTaskCheckbox(
                  isCompleted: task.isCompleted,
                  onTap: () => widget.onToggle(task),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeInOut,
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: completionColor,
                        decorationThickness: 2,
                        color: task.isCompleted
                            ? (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.charcoal)
                            : colors.onSurface,
                      ),
                      child: Text(task.title),
                    ),

                    if (task.description.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 240),
                        opacity: task.isCompleted ? 0.65 : 1.0,
                        child: Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.sm),

                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _Tag(
                          icon: Icons.calendar_today_outlined,
                          label: _dateLabel(task.studyDate),
                        ),
                        _Tag(
                          icon: _priorityIcon(),
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
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
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
                                  key: const ValueKey('completed'),
                                  icon: Icons.check_circle_rounded,
                                  label: 'Completed',
                                  color: completionColor,
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

              const SizedBox(width: AppSpacing.xxs),

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
                        title: const Text('Delete task'),
                      ),
                    ),
                ],
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.walnut : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? AppColors.walnut
                    : (isDark ? AppColors.caramel : AppColors.caramel),
                width: 2,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
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
                      color: isDark ? AppColors.warmSand : Colors.white,
                      size: 18,
                    )
                  : const SizedBox(
                      key: ValueKey('unchecked'),
                      width: 18,
                      height: 18,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: effectiveColor),
            const SizedBox(width: AppSpacing.xxs),
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
