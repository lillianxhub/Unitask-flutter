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
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  void _listenToProjects() {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (_userId == null || userEmail == null) return;
    FirebaseFirestore.instance
        .collection('projects')
        .where(
          Filter.or(
            Filter('members', arrayContains: userEmail),
            Filter('pendingMembers', arrayContains: userEmail),
          ),
        )
        .snapshots()
        .listen((snapshot) {
          _projects = snapshot.docs.map((doc) {
            return Project.fromJson(doc.data(), doc.id);
          }).toList();
          notifyListeners();
        });
  }

  List<Project> get projects => List.unmodifiable(_projects);

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

  Future<void> inviteMember(String projectName, String email) async {
    if (_userId == null) {
      try {
        final project = _projects.firstWhere((p) => p.name == projectName);
        // In local guest mode, we just add directly for simplicity
        if (!project.members.contains(email) &&
            !project.pendingMembers.contains(email)) {
          project.pendingMembers.add(email);
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
          await FirebaseFirestore.instance
              .collection('projects')
              .doc(project.id)
              .update({'pendingMembers': project.pendingMembers});
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
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(project.id)
            .update({'pendingMembers': project.pendingMembers});
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error rejecting invite: $e');
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
