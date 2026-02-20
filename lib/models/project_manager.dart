import 'package:flutter/foundation.dart';
import 'project.dart';
import 'task.dart';

class ProjectManager extends ChangeNotifier {
  ProjectManager._();
  static final ProjectManager _instance = ProjectManager._();
  static ProjectManager get instance => _instance;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Simulate fetching data from a database or API
    // When a real backend is ready, replace this flutter delay with real http/db requests
    await Future.delayed(const Duration(seconds: 2));

    _isInitialized = true;
    notifyListeners();
  }

  final List<Project> _projects = [
    Project(
      name: 'Mobile Project',
      description: 'Flutter Application Development',
      dueDate: '7/1/2569',
      status: 'Doing',
      tasks: [
        Task(
          title: 'Setup UI',
          dueDate: DateTime.now(),
          createdDate: DateTime.now(),
          isCompleted: true,
        ),
        Task(
          title: 'Implement Logic',
          dueDate: DateTime.now(),
          createdDate: DateTime.now(),
          isCompleted: true,
        ),
        Task(
          title: 'Testing',
          dueDate: DateTime.now().add(const Duration(days: 2)),
          createdDate: DateTime.now(),
        ),
      ],
    ),
    Project(
      name: 'Nahi Clinic',
      description: 'Clinic Management System',
      dueDate: '15/2/2569',
      status: 'Doing',
      tasks: [
        Task(
          title: 'Database Design',
          dueDate: DateTime.now(),
          createdDate: DateTime.now(),
          isCompleted: true,
        ),
        Task(
          title: 'Frontend',
          dueDate: DateTime.now(),
          createdDate: DateTime.now(),
        ),
        Task(
          title: 'Backend',
          dueDate: DateTime.now(),
          createdDate: DateTime.now(),
        ),
        Task(
          title: 'Deploy',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          createdDate: DateTime.now(),
        ),
      ],
    ),
  ];

  List<Project> get projects => List.unmodifiable(_projects);

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void addTask(String projectName, Task task) {
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      project.tasks.add(task);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Project not found: $projectName');
      }
    }
  }

  void deleteProject(String projectName) {
    _projects.removeWhere((p) => p.name == projectName);
    notifyListeners();
  }

  void deleteTask(String projectName, Task task) {
    try {
      final project = _projects.firstWhere((p) => p.name == projectName);
      project.tasks.remove(task);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
    }
  }

  // For compatibility with existing code
  List<Project> getAllProjects() => projects;

  // Stats Getters
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
    // Simplified logic for "Weekly Stats" based on existing tasks
    int created = 0;
    int completed = 0;
    int doing = 0;
    int overdue = 0;

    final now = DateTime.now();

    for (var p in _projects) {
      created += p.tasks.length; // Counting all as created for simplicity
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

  // Global Stats for Profile
  int get totalProjectCount => _projects.length;

  int get totalCompletedTaskCount {
    return _projects.fold(
      0,
      (sum, project) => sum + project.tasks.where((t) => t.isCompleted).length,
    );
  }

  int get totalDoingTaskCount {
    return _projects.fold(
      0,
      (sum, project) => sum + project.tasks.where((t) => !t.isCompleted).length,
    );
  }
}
