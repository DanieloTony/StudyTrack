import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_surface.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth < 900
            ? constraints.maxWidth
            : 900.0;
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
                176,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My tasks',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Plan your next small win.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: widget.onAddTask,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add task'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassSurface(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.control),
                  ),
                  showShadow: false,
                  child: TextField(
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
                ),
                const SizedBox(height: AppSpacing.md),
                GlassSurface(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.card),
                  ),
                  showShadow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter and sort',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedButton<TaskFilter>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: TaskFilter.all,
                            label: Text('All'),
                          ),
                          ButtonSegment(
                            value: TaskFilter.pending,
                            label: Text('Pending'),
                          ),
                          ButtonSegment(
                            value: TaskFilter.completed,
                            label: Text('Done'),
                          ),
                        ],
                        selected: {_filter},
                        onSelectionChanged: (selection) {
                          setState(() => _filter = selection.first);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LayoutBuilder(
                        builder: (context, controlConstraints) {
                          final priorityControl =
                              DropdownButtonFormField<TaskPriority?>(
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
                                    (priority) =>
                                        DropdownMenuItem<TaskPriority?>(
                                          value: priority,
                                          child: Text(_priorityLabel(priority)),
                                        ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _priorityFilter = value);
                                },
                              );
                          final sortControl = DropdownButtonFormField<TaskSort>(
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
                          );

                          if (controlConstraints.maxWidth < 520) {
                            return Column(
                              children: [
                                priorityControl,
                                const SizedBox(height: AppSpacing.sm),
                                sortControl,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: priorityControl),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: sortControl),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${visibleTasks.length} '
                        '${visibleTasks.length == 1 ? 'task' : 'tasks'} found',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Reset filters'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                if (widget.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
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
            ),
          ),
        );
      },
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
