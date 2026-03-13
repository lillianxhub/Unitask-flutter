import 'project.dart';

class Task {
  String title;
  String description;
  DateTime dueDate;
  DateTime createdDate;
  bool isCompleted;
  List<String> assignedTo;
  String priority;
  List<Comment> comments;

  Task({
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.createdDate,
    this.isCompleted = false,
    List<String>? assignedTo,
    this.priority = 'Medium',
    List<Comment>? comments,
  })  : assignedTo = assignedTo ?? [],
        comments = comments ?? [];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'isCompleted': isCompleted,
      'assignedTo': assignedTo,
      'priority': priority,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Backward compatible: handle both String (old) and List (new) formats
    List<String> parseAssignedTo(dynamic value) {
      if (value == null) return [];
      if (value is String) return value.isNotEmpty ? [value] : [];
      if (value is List) return List<String>.from(value);
      return [];
    }

    return Task(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      assignedTo: parseAssignedTo(json['assignedTo']),
      priority: json['priority'] ?? 'Medium',
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
    );
  }
}
