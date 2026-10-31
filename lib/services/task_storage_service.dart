
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_task.dart';

/// Small storage interface that can be replaced by a fake in tests.
abstract class TaskStorageBackend {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}

/// Production implementation backed by SharedPreferencesAsync.
class _SharedPreferencesTaskStorageBackend
    implements TaskStorageBackend {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> getString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  @override
  Future<void> remove(String key) {
    return _preferences.remove(key);
  }
}

class TaskStorageService {
  static const String storageKey = 'studytrack_tasks_v1';

  final TaskStorageBackend _backend;

  TaskStorageService({TaskStorageBackend? backend})
      : _backend = backend ?? _SharedPreferencesTaskStorageBackend();

  /// Load all saved tasks.
  Future<List<StudyTask>> loadTasks() async {
    final storedData = await _backend.getString(storageKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedData);

      if (decoded is! List) {
        throw const FormatException(
          'Saved task data must be a JSON list.',
        );
      }

      return decoded.map<StudyTask>((item) {
        if (item is! Map) {
          throw const FormatException(
            'Each saved task must be a JSON object.',
          );
        }

        return StudyTask.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException(
        'Unable to decode saved tasks: $error',
      );
    }
  }

  /// Save the complete task list.
  Future<void> saveTasks(List<StudyTask> tasks) async {
    final encoded = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );

    await _backend.setString(storageKey, encoded);
  }

  /// Remove saved tasks only when explicitly requested.
  Future<void> clearTasks() async {
    await _backend.remove(storageKey);
  }
}
