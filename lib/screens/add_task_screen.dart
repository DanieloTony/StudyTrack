import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_surface.dart';

class AddTaskScreen extends StatefulWidget {
  final StudyTask? initialTask;

  const AddTaskScreen({super.key, this.initialTask});

  bool get isEditing => initialTask != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _studyDate;
  TimeOfDay? _deadlineTime;
  late TaskPriority _priority;
  int _reminderMinutesBefore = 10;

  @override
  void initState() {
    super.initState();

    final task = widget.initialTask;
    final now = DateTime.now();

    _titleController.text = task?.title ?? '';
    _descriptionController.text = task?.description ?? '';

    _studyDate = task?.studyDate ?? DateTime(now.year, now.month, now.day);

    _deadlineTime = task?.deadline == null
        ? null
        : TimeOfDay.fromDateTime(task!.deadline!);

    _priority = task?.priority ?? TaskPriority.medium;
    _reminderMinutesBefore = task?.reminderMinutesBefore ?? 10;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _studyDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null && mounted) {
      setState(() {
        _studyDate = DateTime(selected.year, selected.month, selected.day);
      });
    }
  }

  Future<void> _selectDeadline() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _deadlineTime ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (selected != null && mounted) {
      setState(() => _deadlineTime = selected);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final existingTask = widget.initialTask;

    DateTime? deadline;

    if (_deadlineTime != null) {
      deadline = DateTime(
        _studyDate.year,
        _studyDate.month,
        _studyDate.day,
        _deadlineTime!.hour,
        _deadlineTime!.minute,
      );
    }

    final task = StudyTask(
      id: existingTask?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      studyDate: _studyDate,
      deadline: deadline,
      priority: _priority,
      isCompleted: existingTask?.isCompleted ?? false,
      reminderMinutesBefore: _reminderMinutesBefore,
    );

    Navigator.of(context).pop(task);
  }

  String _priorityName(TaskPriority priority) {
    return '${priority.name[0].toUpperCase()}'
        '${priority.name.substring(1)}';
  }

  String _formatDate(DateTime date) {
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
    final isEditing = widget.isEditing;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit task' : 'New study task')),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
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
              child: Form(
                key: _formKey,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      isEditing
                          ? 'Update your study plan'
                          : 'Plan your next study session',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Set a clear goal and choose when to work on it.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GlassSurface(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            autofocus: !isEditing,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Task title',
                              hintText: 'e.g. Practise Flutter layouts',
                              prefixIcon: Icon(Icons.edit_note_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a task title.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                              hintText: 'What do you want to learn?',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassSurface(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xs,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.control,
                                ),
                              ),
                              leading: _FormIcon(
                                icon: Icons.calendar_month_rounded,
                              ),
                              title: const Text('Study date'),
                              subtitle: Text(_formatDate(_studyDate)),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: _selectDate,
                            ),
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.control,
                                ),
                              ),
                              leading: _FormIcon(icon: Icons.schedule_rounded),
                              title: const Text('Deadline'),
                              subtitle: Text(
                                _deadlineTime == null
                                    ? 'No deadline set'
                                    : _deadlineTime!.format(context),
                              ),
                              trailing: _deadlineTime == null
                                  ? const Icon(Icons.chevron_right_rounded)
                                  : IconButton(
                                      tooltip: 'Remove deadline',
                                      onPressed: () {
                                        setState(() => _deadlineTime = null);
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                              onTap: _selectDeadline,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassSurface(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          DropdownButtonFormField<int>(
                            initialValue: _reminderMinutesBefore,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Deadline reminder',
                              prefixIcon: Icon(
                                Icons.notifications_active_outlined,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('No reminder'),
                              ),
                              DropdownMenuItem(
                                value: 5,
                                child: Text('5 minutes before'),
                              ),
                              DropdownMenuItem(
                                value: 10,
                                child: Text('10 minutes before'),
                              ),
                              DropdownMenuItem(
                                value: 15,
                                child: Text('15 minutes before'),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text('30 minutes before'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _reminderMinutesBefore = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _deadlineTime == null
                                ? 'Set a deadline to use reminders.'
                                : _reminderMinutesBefore == 0
                                ? 'Reminders are turned off for this task.'
                                : 'You will be reminded '
                                      '$_reminderMinutesBefore minutes before the deadline.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassSurface(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          LayoutBuilder(
                            builder: (context, priorityConstraints) {
                              final itemWidth =
                                  (priorityConstraints.maxWidth -
                                      AppSpacing.sm * 2) /
                                  3;

                              return Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: TaskPriority.values.map((priority) {
                                  final selected = _priority == priority;
                                  return SizedBox(
                                    width: itemWidth,
                                    child: _PriorityOption(
                                      label: _priorityName(priority),
                                      selected: selected,
                                      onTap: () {
                                        setState(() => _priority = priority);
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    LayoutBuilder(
                      builder: (context, actionConstraints) {
                        final cancelButton = OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        );
                        final saveButton = FilledButton.icon(
                          onPressed: _saveTask,
                          icon: Icon(
                            isEditing
                                ? Icons.save_rounded
                                : Icons.check_rounded,
                          ),
                          label: Text(
                            isEditing ? 'Save changes' : 'Save study task',
                          ),
                        );

                        if (actionConstraints.maxWidth < 400) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              cancelButton,
                              const SizedBox(height: AppSpacing.sm),
                              saveButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: cancelButton),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(flex: 2, child: saveButton),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FormIcon extends StatelessWidget {
  final IconData icon;

  const _FormIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.primary.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.1,
        ),
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Icon(icon, color: colors.primary, size: 20),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label priority',
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.control),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: colors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? colors.primary : colors.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
