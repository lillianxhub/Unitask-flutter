import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'project.dart';
import 'task.dart';

class ProjectManager extends ChangeNotifier {
  ProjectManager._() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _userId = user.uid;
        _listenToProjects();
      } else {
        _userId = null;
        _projects.clear();
        notifyListeners();
      }
    });
  }

  static final ProjectManager _instance = ProjectManager._();
  static ProjectManager get instance => _instance;

  String? _userId;
  List<Project> _projects = [];
  final Map<String, Project> _memberProjectsMap = {};
  final Map<String, Project> _pendingProjectsMap = {};
  List<AppNotification> _notifications = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  void _updateCombinedProjects() {
    final Map<String, Project> combined = {};
    combined.addAll(_memberProjectsMap);
    combined.addAll(_pendingProjectsMap);
    _projects = combined.values.toList();
    // Sort logic if needed, but previously wasn't sorted here.
    notifyListeners();
  }

  void _listenToProjects() {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userId == null || userEmail == null) return;

    FirebaseFirestore.instance
        .collection('projects')
        .where('members', arrayContains: userEmail)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              _memberProjectsMap.clear();
              for (var doc in snapshot.docs) {
                _memberProjectsMap[doc.id] = Project.fromJson(
                  doc.data(),
                  doc.id,
                );
              }
              _updateCombinedProjects();
            } catch (e) {
              if (kDebugMode) print('Error parsing member projects: $e');
            }
          },
          onError: (error) {
            if (kDebugMode) print('Error listening to member projects: $error');
          },
        );

    FirebaseFirestore.instance
        .collection('projects')
        .where('pendingMembers', arrayContains: userEmail)
        .snapshots()
        .listen(
          (snapshot) {
            try {
              _pendingProjectsMap.clear();
              for (var doc in snapshot.docs) {
                _pendingProjectsMap[doc.id] = Project.fromJson(
                  doc.data(),
                  doc.id,
                );
              }
              _updateCombinedProjects();
            } catch (e) {
              if (kDebugMode) print('Error parsing pending projects: $e');
            }
          },
          onError: (error) {
            if (kDebugMode) {
              print('Error listening to pending projects: $error');
            }
          },
        );

    FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientEmail', isEqualTo: userEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _notifications = snapshot.docs.map((doc) {
              return AppNotification.fromJson(doc.data(), doc.id);
            }).toList();
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Error listening to notifications: $error');
          },
        );
  }

  List<Project> get projects {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userId == null || userEmail == null)
      return List.unmodifiable(_projects);
    return _projects.where((p) => p.members.contains(userEmail)).toList();
  }

  List<Project> get pendingProjects {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userId == null || userEmail == null) return [];
    return _projects
        .where((p) => p.pendingMembers.contains(userEmail))
        .toList();
  }

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationsCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (_userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      if (kDebugMode) print('Error marking notification read: $e');
    }
  }

  Future<void> addProject(Project project) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userId == null || userEmail == null) {
      _projects.add(project);
      notifyListeners();
      return;
    }

    // Ensure the creator is in the members list
    if (!project.members.contains(userEmail)) {
      project.members.add(userEmail);
    }
    project.memberRoles[userEmail] = 'Owner';

    await FirebaseFirestore.instance
        .collection('projects')
        .add(project.toJson());
  }

  Future<void> addTask(String projectName, Task task) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        project.tasks.add(task);
        notifyListeners();
      } catch (e) {}
      return;
    }
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        project.tasks.add(task);
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({'tasks': project.tasks.map((t) => t.toJson()).toList()});

        // Create notifications for all other members about the new task
        final batch = FirebaseFirestore.instance.batch();
        final notificationsRef = FirebaseFirestore.instance.collection(
          'notifications',
        );
        final senderEmail =
            FirebaseAuth.instance.currentUser?.email ?? 'System';
        // Let's attempt to fetch the sender's name if we can, else just use the part of email before @
        String senderName = senderEmail.split('@').first;

        final dateString =
            '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}';
        final priorityString = task.priority.isNotEmpty
            ? task.priority
            : 'Not Set';

        for (final memberEmail in project.members) {
          if (memberEmail != senderEmail) {
            final docRef = notificationsRef.doc();
            batch.set(docRef, {
              'id': docRef.id,
              'recipientEmail': memberEmail,
              'projectId': project.id,
              'projectName': project.name,
              'senderName': senderName,
              'senderEmail': senderEmail,
              'type': 'task',
              'text':
                  'New Task: ${task.title}\nDue: $dateString\nPriority: $priorityString',
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
            });
          }
        }
        await batch.commit();

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error adding task: $e');
    }
  }

  Future<void> deleteProject(String projectName) async {
    if (_userId == null) {
      _projects.removeWhere((p) => p.name == projectName);
      notifyListeners();
      return;
    }
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .delete();
      }
    } catch (e) {
      if (kDebugMode) print('Error deleting project: $e');
    }
  }

  Future<void> deleteTask(String projectName, Task task) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        project.tasks.remove(task);
        notifyListeners();
      } catch (e) {}
      return;
    }
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        project.tasks.removeWhere(
          (t) =>
              t.title == task.title &&
              t.createdDate.toIso8601String() ==
                  task.createdDate.toIso8601String(),
        );
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({'tasks': project.tasks.map((t) => t.toJson()).toList()});
      }
    } catch (e) {
      if (kDebugMode) print('Error deleting task: $e');
    }
  }

  Future<void> updateTask(
    String projectName,
    Task oldTask,
    Task newTask,
  ) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        final index = project.tasks.indexWhere(
          (t) =>
              t.title == oldTask.title &&
              t.createdDate.toIso8601String() ==
                  oldTask.createdDate.toIso8601String(),
        );
        if (index != -1) {
          project.tasks[index] = newTask;
          notifyListeners();
        }
      } catch (e) {}
      return;
    }
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        final index = project.tasks.indexWhere(
          (t) =>
              t.title == oldTask.title &&
              t.createdDate.toIso8601String() ==
                  oldTask.createdDate.toIso8601String(),
        );
        if (index != -1) {
          project.tasks[index] = newTask;
          await FirebaseFirestore.instance
              .collection('projects')
              .doc(project.id)
              .update({'tasks': project.tasks.map((t) => t.toJson()).toList()});
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error updating task: $e');
    }
  }

  Future<void> addTaskComment(
    String projectName,
    Task task,
    Comment comment,
  ) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        final taskToUpdate = project.tasks.firstWhere(
          (t) =>
              t.title == task.title &&
              t.createdDate.toIso8601String() ==
                  task.createdDate.toIso8601String(),
        );
        taskToUpdate.comments.add(comment);
        notifyListeners();
      } catch (e) {}
      return;
    }
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        final taskToUpdate = project.tasks.firstWhere(
          (t) =>
              t.title == task.title &&
              t.createdDate.toIso8601String() ==
                  task.createdDate.toIso8601String(),
        );
        taskToUpdate.comments.add(comment);
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({'tasks': project.tasks.map((t) => t.toJson()).toList()});

        // Create notifications for all other members
        final batch = FirebaseFirestore.instance.batch();
        final notificationsRef = FirebaseFirestore.instance.collection(
          'notifications',
        );

        for (final memberEmail in project.members) {
          if (memberEmail != comment.authorEmail) {
            final docRef = notificationsRef.doc();
            batch.set(docRef, {
              'id': docRef.id,
              'recipientEmail': memberEmail,
              'projectId': project.id,
              'projectName': project.name,
              'senderName': comment.authorName,
              'senderEmail': comment.authorEmail,
              'type': 'comment',
              'text': '[Task: ${task.title}] ${comment.text}',
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
            });
          }
        }
        await batch.commit();

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error adding task comment: $e');
    }
  }

  Future<void> addComment(String projectName, Comment comment) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        project.comments.add(comment);
        notifyListeners();
      } catch (e) {}
      return;
    }

    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        // 1. Add comment to project
        project.comments.add(comment);
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({
              'comments': project.comments.map((c) => c.toJson()).toList(),
            });

        // 2. Create notifications for all other members
        final batch = FirebaseFirestore.instance.batch();
        final notificationsRef = FirebaseFirestore.instance.collection(
          'notifications',
        );

        for (final memberEmail in project.members) {
          if (memberEmail != comment.authorEmail) {
            final docRef = notificationsRef.doc();
            batch.set(docRef, {
              'id': docRef.id,
              'recipientEmail': memberEmail,
              'projectId': project.id,
              'projectName': project.name,
              'senderName': comment.authorName,
              'senderEmail': comment.authorEmail,
              'type': 'comment',
              'text': comment.text,
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
            });
          }
        }
        await batch.commit();

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error adding comment: $e');
    }
  }

  Future<void> inviteMember(
    String projectName,
    String email,
    String role,
  ) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        // In local guest mode, we just add directly for simplicity
        if (!project.members.contains(email) &&
            !project.pendingMembers.contains(email)) {
          project.pendingMembers.add(email);
          project.memberRoles[email] = role;
          notifyListeners();
        }
      } catch (e) {}
      return;
    }
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        if (!project.members.contains(email) &&
            !project.pendingMembers.contains(email)) {
          project.pendingMembers.add(email);
          project.memberRoles[email] = role;
          await FirebaseFirestore.instance
              .collection('projects')
              .doc(project.id)
              .update({
                'pendingMembers': project.pendingMembers,
                'memberRoles': project.memberRoles,
              });
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error inviting member: $e');
    }
  }

  Future<void> acceptInvite(String projectId) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userId == null || userEmail == null) return;

    try {
      final project = _projects.firstWhere((p) => p.id == projectId);
      if (project.pendingMembers.contains(userEmail)) {
        project.pendingMembers.remove(userEmail);
        if (!project.members.contains(userEmail)) {
          project.members.add(userEmail);
        }
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({
              'members': project.members,
              'pendingMembers': project.pendingMembers,
            });
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error accepting invite: $e');
    }
  }

  Future<void> rejectInvite(String projectId) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userId == null || userEmail == null) return;

    try {
      final project = _projects.firstWhere((p) => p.id == projectId);
      if (project.pendingMembers.contains(userEmail)) {
        project.pendingMembers.remove(userEmail);
        project.memberRoles.remove(userEmail);
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({
              'pendingMembers': project.pendingMembers,
              'memberRoles': project.memberRoles,
            });
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error rejecting invite: $e');
    }
  }

  Future<void> removeMember(String projectName, String email) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        project.members.remove(email);
        project.memberRoles.remove(email);
        notifyListeners();
      } catch (e) {}
      return;
    }

    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        project.members.remove(email);
        project.memberRoles.remove(email);
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({
              'members': project.members,
              'memberRoles': project.memberRoles,
            });
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error removing member: $e');
    }
  }

  Future<void> updateMemberRole(
    String projectName,
    String email,
    String newRole,
  ) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        if (project.members.contains(email) ||
            project.pendingMembers.contains(email)) {
          project.memberRoles[email] = newRole;
          notifyListeners();
        }
      } catch (e) {}
      return;
    }

    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      if (project.id != null) {
        if (project.members.contains(email) ||
            project.pendingMembers.contains(email)) {
          project.memberRoles[email] = newRole;
          await FirebaseFirestore.instance
              .collection('projects')
              .doc(project.id)
              .update({'memberRoles': project.memberRoles});
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error updating member role: $e');
    }
  }

  List<Project> getAllProjects() => projects;

  int get successRate {
    int totalTasks = 0;
    int completedTasks = 0;
    for (var p in _projects) {
      totalTasks += p.tasks.length;
      completedTasks += p.tasks.where((t) => t.isCompleted).length;
    }
    if (totalTasks == 0) return 0;
    return ((completedTasks / totalTasks) * 100).round();
  }

  int get completedTasksCount {
    int count = 0;
    for (var p in _projects) {
      count += p.tasks.where((t) => t.isCompleted).length;
    }
    return count;
  }

  Map<String, int> get weeklyStats {
    int created = 0;
    int completed = 0;
    int doing = 0;
    int overdue = 0;

    final now = DateTime.now();

    for (var p in _projects) {
      created += p.tasks.length;
      completed += p.tasks.where((t) => t.isCompleted).length;
      doing += p.tasks.where((t) => !t.isCompleted).length;
      overdue += p.tasks
          .where((t) => !t.isCompleted && t.dueDate.isBefore(now))
          .length;
    }

    return {
      'created': created,
      'completed': completed,
      'doing': doing,
      'overdue': overdue,
    };
  }

  int get totalProjectCount => _projects.length;

  int get totalCompletedTaskCount {
    return _projects.fold(
      0,
      (total, project) =>
          total + project.tasks.where((t) => t.isCompleted).length,
    );
  }

  int get totalDoingTaskCount {
    return _projects.fold(
      0,
      (total, project) =>
          total + project.tasks.where((t) => !t.isCompleted).length,
    );
  }
}

class AppNotification {
  final String id;
  final String recipientEmail;
  final String projectId;
  final String projectName;
  final String senderName;
  final String senderEmail;
  final String type; // 'comment', 'invite', etc.
  final String text;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.recipientEmail,
    required this.projectId,
    required this.projectName,
    required this.senderName,
    required this.senderEmail,
    required this.type,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json, String id) {
    return AppNotification(
      id: id,
      recipientEmail: json['recipientEmail'] ?? '',
      projectId: json['projectId'] ?? '',
      projectName: json['projectName'] ?? '',
      senderName: json['senderName'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}
