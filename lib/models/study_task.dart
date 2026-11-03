
enum TaskPriority { low, medium, high }

class StudyTask {
  final String id;
  final String title;
  final String description;
  final DateTime studyDate;
  final DateTime? deadline;
  final TaskPriority priority;
  final bool isCompleted;
  final int reminderMinutesBefore;

  const StudyTask({
    required this.id,
    required this.title,
    this.description = '',
    required this.studyDate,
    this.deadline,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.reminderMinutesBefore = 10,
  });

  StudyTask copyWith({
    String? title,
    String? description,
    DateTime? studyDate,
    DateTime? deadline,
    bool clearDeadline = false,
    TaskPriority? priority,
    bool? isCompleted,
    int? reminderMinutesBefore,
  }) {
    return StudyTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      studyDate: studyDate ?? this.studyDate,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'studyDate': studyDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    final rawPriority = json['priority'];
    final priorityName = switch (rawPriority) {
      TaskPriority priority => priority.name,
      String value => value.trim(),
      _ => 'medium',
    };

    final reminderValue = json['reminderMinutesBefore'];
    final reminderMinutesBefore = switch (reminderValue) {
      num value => value.toInt(),
      String value => int.tryParse(value) ?? 10,
      _ => 10,
    };

    return StudyTask(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled task',
      description: json['description'] as String? ?? '',
      studyDate: DateTime.tryParse(
            json['studyDate']?.toString() ??
                json['date']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      priority: TaskPriority.values.firstWhere(
        (item) => item.name.toLowerCase() == priorityName.toLowerCase(),
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }
}
