import 'project.dart';

class Task {
  String title;
  String description;
  DateTime dueDate;
  DateTime createdDate;
  List<String> assignedTo;
  List<String> completedBy;
  String priority;
  List<Comment> comments;

  /// Task is completed when all assigned members have marked it done.
  /// If no one is assigned, falls back to the stored _isCompleted flag.
  bool get isCompleted {
    if (assignedTo.isEmpty) return _isCompleted;
    return assignedTo.every((e) => completedBy.contains(e));
  }

  set isCompleted(bool value) {
    _isCompleted = value;
    if (value && assignedTo.isNotEmpty) {
      // Mark all assignees as completed
      for (final email in assignedTo) {
        if (!completedBy.contains(email)) {
          completedBy.add(email);
        }
      }
    } else if (!value) {
      completedBy.clear();
    }
  }

  bool _isCompleted;

  /// Progress 0.0 to 1.0 based on how many assignees have completed.
  double get progress {
    if (assignedTo.isEmpty) return _isCompleted ? 1.0 : 0.0;
    final done = assignedTo.where((e) => completedBy.contains(e)).length;
    return done / assignedTo.length;
  }

  /// Count of completed assignees.
  int get completedCount {
    if (assignedTo.isEmpty) return _isCompleted ? 1 : 0;
    return assignedTo.where((e) => completedBy.contains(e)).length;
  }

  Task({
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.createdDate,
    bool isCompleted = false,
    List<String>? assignedTo,
    List<String>? completedBy,
    this.priority = 'Medium',
    List<Comment>? comments,
  })  : _isCompleted = isCompleted,
        assignedTo = assignedTo ?? [],
        completedBy = completedBy ?? [],
        comments = comments ?? [];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'isCompleted': isCompleted,
      'assignedTo': assignedTo,
      'completedBy': completedBy,
      'priority': priority,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Backward compatible: handle both String (old) and List (new) formats
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is String) return value.isNotEmpty ? [value] : [];
      if (value is List) return List<String>.from(value);
      return [];
    }

    final assignedTo = parseStringList(json['assignedTo']);
    final bool isCompletedRaw = json['isCompleted'] ?? false;
    List<String> completedBy = parseStringList(json['completedBy']);

    // Backward compat: if old data has isCompleted=true but no completedBy,
    // assume all assignees completed
    if (isCompletedRaw && completedBy.isEmpty && assignedTo.isNotEmpty) {
      completedBy = List<String>.from(assignedTo);
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
      isCompleted: isCompletedRaw,
      assignedTo: assignedTo,
      completedBy: completedBy,
      priority: json['priority'] ?? 'Medium',
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
    );
  }
}
