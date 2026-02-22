import 'task.dart';

class Project {
  String? id;
  final String name;
  final String description;
  final String dueDate;
  final List<String> members;
  final List<String> pendingMembers;
  final String ownerId;
  final String status;
  final List<Task> tasks;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.ownerId,
    List<String>? members,
    List<String>? pendingMembers,
    this.status = 'Doing',
    List<Task>? tasks,
  }) : tasks = tasks ?? [],
       members = members ?? [],
       pendingMembers = pendingMembers ?? [];

  int get progress {
    if (tasks.isEmpty) return 0;
    int completedCount = tasks.where((t) => t.isCompleted).length;
    return ((completedCount / tasks.length) * 100).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'dueDate': dueDate,
      'ownerId': ownerId,
      'members': members,
      'pendingMembers': pendingMembers,
      'status': status,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json, [String? id]) {
    return Project(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] ?? '',
      ownerId: json['ownerId'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      pendingMembers: List<String>.from(json['pendingMembers'] ?? []),
      status: json['status'] ?? 'Doing',
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((t) => Task.fromJson(t))
              .toList() ??
          [],
    );
  }
}
