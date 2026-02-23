import 'task.dart';

class Project {
  String? id;
  final String name;
  final String description;
  final String dueDate;
  final List<String> members;
  final List<String> pendingMembers;
  final Map<String, dynamic> memberRoles;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String status;
  final List<Task> tasks;
  final List<Comment> comments;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.ownerId,
    this.ownerName = '',
    this.ownerEmail = '',
    List<String>? members,
    List<String>? pendingMembers,
    Map<String, dynamic>? memberRoles,
    this.status = 'Doing',
    List<Task>? tasks,
    List<Comment>? comments,
  }) : tasks = tasks ?? [],
       comments = comments ?? [],
       members = members ?? [],
       pendingMembers = pendingMembers ?? [],
       memberRoles = memberRoles ?? {};

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
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'members': members,
      'pendingMembers': pendingMembers,
      'memberRoles': memberRoles,
      'status': status,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json, [String? id]) {
    return Project(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      pendingMembers: List<String>.from(json['pendingMembers'] ?? []),
      memberRoles: Map<String, dynamic>.from(json['memberRoles'] ?? {}),
      status: json['status'] ?? 'Doing',
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((t) => Task.fromJson(t))
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class Comment {
  final String id;
  final String authorEmail;
  final String authorName;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorEmail,
    required this.authorName,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorEmail': authorEmail,
      'authorName': authorName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      authorEmail: json['authorEmail'] ?? '',
      authorName: json['authorName'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
