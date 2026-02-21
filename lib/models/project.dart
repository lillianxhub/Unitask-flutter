import 'task.dart';

class Project {
  final String name;
  final String description;
  final String dueDate;
  final String? memberEmail;
  final String status;
  final List<Task> tasks;

  Project({
    required this.name,
    required this.description,
    required this.dueDate,
    this.memberEmail,
    this.status = 'Doing',
    List<Task>? tasks,
  }) : tasks = tasks ?? [];

  int get progress {
    if (tasks.isEmpty) return 0;
    int completedCount = tasks.where((t) => t.isCompleted).length;
    return ((completedCount / tasks.length) * 100).round();
  }
}
