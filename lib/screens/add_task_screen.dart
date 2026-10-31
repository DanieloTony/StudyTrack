import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit task' : 'New study task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              isEditing
                  ? 'Update your study plan ✏️'
                  : 'Plan your next small win 🌱',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Set a clear goal and choose when to work on it.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

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

            const SizedBox(height: 16),

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

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.calendar_month_rounded,
                color: colors.primary,
              ),
              title: const Text('Study date'),
              subtitle: Text(_formatDate(_studyDate)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _selectDate,
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.schedule_rounded, color: colors.primary),
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

            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: _reminderMinutesBefore,
              decoration: const InputDecoration(
                labelText: 'Deadline reminder',
                prefixIcon: Icon(Icons.notifications_active_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('No reminder')),
                DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                DropdownMenuItem(value: 30, child: Text('30 minutes before')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _reminderMinutesBefore = value;
                  });
                }
              },
            ),

            const SizedBox(height: 8),

            Text(
              _deadlineTime == null
                  ? 'Set a deadline to use reminders.'
                  : _reminderMinutesBefore == 0
                  ? 'Reminders are turned off for this task.'
                  : 'You will be reminded '
                        '$_reminderMinutesBefore minutes before the deadline.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 20),

            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: TaskPriority.values.map((priority) {
                return ChoiceChip(
                  label: Text(_priorityName(priority)),
                  selected: _priority == priority,
                  onSelected: (_) {
                    setState(() => _priority = priority);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _saveTask,
              icon: Icon(isEditing ? Icons.save_rounded : Icons.check_rounded),
              label: Text(isEditing ? 'Save changes' : 'Save study task'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
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
}
