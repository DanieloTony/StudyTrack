
import 'package:flutter_test/flutter_test.dart';

import 'package:studytrack/models/study_task.dart';
import 'package:studytrack/services/task_storage_service.dart';

/// An isolated in-memory backend. It never accesses app storage.
class FakeTaskStorageBackend implements TaskStorageBackend {
  final Map<String, String> values = {};

  @override
  Future<String?> getString(String key) async {
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

void main() {
  late FakeTaskStorageBackend backend;
  late TaskStorageService storage;

  setUp(() {
    backend = FakeTaskStorageBackend();
    storage = TaskStorageService(backend: backend);
  });

  StudyTask createTestTask() {
    return StudyTask(
      id: 'phase5-test-001',
      title: 'Automated Storage Test',
      description: 'Verify saving and loading tasks',
      studyDate: DateTime(2026, 10, 22),
      deadline: DateTime(2026, 10, 22, 18, 30),
      priority: TaskPriority.high,
      isCompleted: false,
    );
  }

  group('TaskStorageService', () {
    test('saves and loads tasks with all details preserved', () async {
      final task = createTestTask();

      await storage.saveTasks([task]);

      final loadedTasks = await storage.loadTasks();

      expect(loadedTasks, hasLength(1));
      expect(loadedTasks.single.toJson(), equals(task.toJson()));
      expect(
        backend.values,
        contains(TaskStorageService.storageKey),
      );
    });

    test('returns an empty list when storage is empty', () async {
      final loadedTasks = await storage.loadTasks();

      expect(loadedTasks, isEmpty);
    });

    test('throws FormatException when saved JSON is malformed', () async {
      backend.values[TaskStorageService.storageKey] =
          '{"title": "unfinished JSON"';

      await expectLater(
        storage.loadTasks(),
        throwsA(isA<FormatException>()),
      );

      // Confirm the invalid data has not been deleted or replaced.
      expect(
        backend.values[TaskStorageService.storageKey],
        '{"title": "unfinished JSON"',
      );
    });

    test('throws FormatException when saved JSON is not a list', () async {
      backend.values[TaskStorageService.storageKey] =
          '{"title": "This is an object, not a list"}';

      await expectLater(
        storage.loadTasks(),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
