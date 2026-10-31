import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../screens/add_task_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tasks_screen.dart';
import '../services/notification_service.dart';
import '../services/task_storage_service.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TaskStorageService _storageService = TaskStorageService();

  static const Duration _snackBarDuration = Duration(seconds: 3);

  List<StudyTask> _tasks = [];

  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeNotificationsAndTasks();
  }

  Future<void> _initializeNotificationsAndTasks() async {
    try {
      await NotificationService.instance.initialize();
    } catch (error) {
      debugPrint('Notification initialization failed: $error');
    }

    await _loadTasks();
  }

  Future<void> _syncTaskReminders() async {
    try {
      await NotificationService.instance.syncTaskReminders(_tasks);
    } catch (error) {
      debugPrint('Unable to synchronize task reminders: $error');
    }
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final savedTasks = await _storageService.loadTasks();

      if (!mounted) return;

      setState(() {
        _tasks = savedTasks;
        _isLoading = false;
        _loadFailed = false;
      });

      await _syncTaskReminders();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });

      _showMessage(
        'Unable to load saved tasks. Your stored data has not been cleared.',
      );
    }
  }

  Future<bool> _saveTasks() async {
    if (_isSaving) return false;

    _isSaving = true;

    try {
      await _storageService.saveTasks(_tasks);

      if (mounted) {
        setState(() {
          _loadFailed = false;
        });
      }

      return true;
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to save your tasks. Please try again.');
      }

      return false;
    } finally {
      _isSaving = false;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: _snackBarDuration,
          behavior: SnackBarBehavior.fixed,
        ),
      );
  }

  Future<void> _openAddTask() async {
    if (_isLoading || _loadFailed) {
      _showMessage('Please resolve the loading issue before adding tasks.');
      return;
    }

    final result = await Navigator.of(
      context,
    ).push<StudyTask>(MaterialPageRoute(builder: (_) => const AddTaskScreen()));

    if (result == null || !mounted) return;

    final previousTasks = List<StudyTask>.from(_tasks);

    setState(() {
      _tasks.insert(0, result);
    });

    final saved = await _saveTasks();

    if (!mounted) return;

    if (!saved) {
      setState(() {
        _tasks = previousTasks;
      });
      return;
    }

    await _syncTaskReminders();

    _showMessage('Task added successfully 🌿');
  }

  Future<void> _editTask(StudyTask task) async {
    if (_isLoading || _loadFailed) {
      _showMessage('Unable to edit tasks while saved data is unavailable.');
      return;
    }

    final result = await Navigator.of(context).push<StudyTask>(
      MaterialPageRoute(builder: (_) => AddTaskScreen(initialTask: task)),
    );

    if (result == null || !mounted) return;

    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) return;

    final previousTask = _tasks[index];

    setState(() {
      _tasks[index] = result;
    });

    final saved = await _saveTasks();

    if (!mounted) return;

    if (!saved) {
      setState(() {
        final currentIndex = _tasks.indexWhere((item) => item.id == task.id);

        if (currentIndex != -1) {
          _tasks[currentIndex] = previousTask;
        }
      });
      return;
    }

    await _syncTaskReminders();

    _showMessage('Task updated successfully 🌿');
  }

  Future<void> _toggleTask(StudyTask task) async {
    if (_isLoading || _loadFailed) return;

    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) return;

    final previousTask = _tasks[index];

    final updatedTask = previousTask.copyWith(
      isCompleted: !previousTask.isCompleted,
    );

    setState(() {
      _tasks[index] = updatedTask;
    });

    final saved = await _saveTasks();

    if (!mounted) return;

    if (!saved) {
      setState(() {
        final currentIndex = _tasks.indexWhere((item) => item.id == task.id);

        if (currentIndex != -1) {
          _tasks[currentIndex] = previousTask;
        }
      });
      return;
    }

    await _syncTaskReminders();

    _showMessage(
      updatedTask.isCompleted
          ? 'Task completed! Great work 🎉'
          : 'Task marked as pending.',
    );
  }

  Future<bool> _deleteTask(StudyTask task) async {
    if (_isLoading || _loadFailed) return false;

    final originalIndex = _tasks.indexWhere((item) => item.id == task.id);

    if (originalIndex == -1) return false;

    final previousTasks = List<StudyTask>.from(_tasks);

    setState(() {
      _tasks.removeAt(originalIndex);
    });

    final saved = await _saveTasks();

    if (!mounted) return false;

    if (!saved) {
      setState(() {
        _tasks = previousTasks;
      });
      return false;
    }

    await _syncTaskReminders();

    if (!mounted) return false;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          duration: _snackBarDuration,
          behavior: SnackBarBehavior.fixed,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              _restoreTask(task, originalIndex);
            },
          ),
        ),
      );

    return true;
  }

  Future<void> _restoreTask(StudyTask task, int originalIndex) async {
    if (!mounted || _isLoading || _loadFailed) return;

    if (_tasks.any((item) => item.id == task.id)) {
      _showMessage('This task is already restored.');
      return;
    }

    final previousTasks = List<StudyTask>.from(_tasks);

    setState(() {
      final insertIndex = originalIndex.clamp(0, _tasks.length).toInt();

      _tasks.insert(insertIndex, task);
    });

    final saved = await _saveTasks();

    if (!mounted) return;

    if (!saved) {
      setState(() {
        _tasks = previousTasks;
      });
      return;
    }

    await _syncTaskReminders();

    _showMessage('Task restored successfully 🌿');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        tasks: _tasks,
        isLoading: _isLoading,
        hasLoadError: _loadFailed,
        onRetryLoad: _loadTasks,
        onAddTask: _openAddTask,
        onShowTasks: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        onToggleTask: _toggleTask,
        onEditTask: _editTask,
      ),
      TasksScreen(
        tasks: _tasks,
        isLoading: _isLoading,
        onAddTask: _openAddTask,
        onToggleTask: _toggleTask,
        onDeleteTask: _deleteTask,
        onEditTask: _editTask,
      ),
      SettingsScreen(
        tasks: _tasks,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: pages[_selectedIndex],
        ),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _openAddTask,
              icon: const Icon(Icons.add),
              label: const Text('New task'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
