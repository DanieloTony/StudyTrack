import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_tile.dart';

enum TaskFilter { all, pending, completed }

enum TaskSort { newest, studyDate, deadline, priority }

class TasksScreen extends StatefulWidget {
  final List<StudyTask> tasks;
  final bool isLoading;
  final VoidCallback onAddTask;
  final ValueChanged<StudyTask> onToggleTask;
  final Future<bool> Function(StudyTask) onDeleteTask;
  final ValueChanged<StudyTask> onEditTask;

  const TasksScreen({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onEditTask,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  TaskFilter _filter = TaskFilter.all;
  TaskPriority? _priorityFilter;
  TaskSort _sort = TaskSort.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudyTask> get _visibleTasks {
    final query = _searchController.text.trim().toLowerCase();

    final result = widget.tasks.where((task) {
      final matchesSearch =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);

      final matchesStatus = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };

      final matchesPriority =
          _priorityFilter == null || task.priority == _priorityFilter;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();

    result.sort(_compareTasks);
    return result;
  }

  int _compareTasks(StudyTask a, StudyTask b) {
    switch (_sort) {
      case TaskSort.newest:
        return b.id.compareTo(a.id);

      case TaskSort.studyDate:
        final dateCompare = a.studyDate.compareTo(b.studyDate);
        if (dateCompare != 0) return dateCompare;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());

      case TaskSort.deadline:
        if (a.deadline == null && b.deadline == null) {
          return a.studyDate.compareTo(b.studyDate);
        }
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);

      case TaskSort.priority:
        const rank = {
          TaskPriority.high: 0,
          TaskPriority.medium: 1,
          TaskPriority.low: 2,
        };

        final priorityCompare = rank[a.priority]!.compareTo(rank[b.priority]!);

        if (priorityCompare != 0) return priorityCompare;

        if (a.deadline != null && b.deadline != null) {
          return a.deadline!.compareTo(b.deadline!);
        }

        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filter = TaskFilter.all;
      _priorityFilter = null;
      _sort = TaskSort.newest;
    });
  }

  String _sortLabel(TaskSort sort) {
    switch (sort) {
      case TaskSort.newest:
        return 'Recently added';
      case TaskSort.studyDate:
        return 'Study date';
      case TaskSort.deadline:
        return 'Nearest deadline';
      case TaskSort.priority:
        return 'Priority';
    }
  }

  String _priorityLabel(TaskPriority priority) {
    return '${priority.name[0].toUpperCase()}'
        '${priority.name.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _visibleTasks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My tasks',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Plan your next small win.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Add task',
              onPressed: widget.onAddTask,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),

        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search title or description...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 18),

        SegmentedButton<TaskFilter>(
          segments: const [
            ButtonSegment(value: TaskFilter.all, label: Text('All')),
            ButtonSegment(value: TaskFilter.pending, label: Text('Pending')),
            ButtonSegment(value: TaskFilter.completed, label: Text('Done')),
          ],
          selected: {_filter},
          onSelectionChanged: (selection) {
            setState(() => _filter = selection.first);
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<TaskPriority?>(
                initialValue: _priorityFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: [
                  const DropdownMenuItem<TaskPriority?>(
                    value: null,
                    child: Text('All priorities'),
                  ),
                  ...TaskPriority.values.map(
                    (priority) => DropdownMenuItem<TaskPriority?>(
                      value: priority,
                      child: Text(_priorityLabel(priority)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _priorityFilter = value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<TaskSort>(
                initialValue: _sort,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Sort by',
                  prefixIcon: Icon(Icons.sort_rounded),
                ),
                items: TaskSort.values.map((sort) {
                  return DropdownMenuItem<TaskSort>(
                    value: sort,
                    child: Text(
                      _sortLabel(sort),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sort = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: Text(
                '${visibleTasks.length} '
                '${visibleTasks.length == 1 ? 'task' : 'tasks'} found',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(onPressed: _clearFilters, child: const Text('Reset')),
          ],
        ),
        const SizedBox(height: 8),

        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (visibleTasks.isEmpty)
          EmptyState(
            title: widget.tasks.isEmpty
                ? 'No tasks yet 🌱'
                : 'No matching tasks',
            message: widget.tasks.isEmpty
                ? 'Create your first study task to get started.'
                : 'Try another search or change your filters.',
            icon: Icons.search_off_rounded,
          )
        else
          ...visibleTasks.map(
            (task) => _AnimatedTaskRow(
              key: ValueKey('animated-${task.id}'),
              onDelete: () => widget.onDeleteTask(task),
              builder: (startDelete) => TaskTile(
                key: ValueKey(task.id),
                task: task,
                onToggle: widget.onToggleTask,
                onEdit: widget.onEditTask,
                onDelete: (_) => startDelete(),
              ),
            ),
          ),
      ],
    );
  }
}

/// Animates a task out before asking MainScreen to delete it.
/// If persistence fails, the row animates back into view.
class _AnimatedTaskRow extends StatefulWidget {
  final Widget Function(VoidCallback startDelete) builder;
  final Future<bool> Function() onDelete;

  const _AnimatedTaskRow({
    super.key,
    required this.builder,
    required this.onDelete,
  });

  @override
  State<_AnimatedTaskRow> createState() => _AnimatedTaskRowState();
}

class _AnimatedTaskRowState extends State<_AnimatedTaskRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 0,
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _slide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  Future<void> _startDelete() async {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);

    try {
      await _controller.reverse();

      if (!mounted) return;

      final succeeded = await widget.onDelete();

      if (!mounted) return;

      if (!succeeded) {
        setState(() => _isDeleting = false);
        await _controller.forward();
      }
      // On success, MainScreen removes this task from the list.
      // Undo inserts it again, creating a new animated row.
    } catch (_) {
      if (!mounted) return;

      setState(() => _isDeleting = false);
      await _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _fade,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: IgnorePointer(
            ignoring: _isDeleting,
            child: widget.builder(_startDelete),
          ),
        ),
      ),
    );
  }
}
