import 'project.dart';

class ProjectManager {
  ProjectManager._();
  static final ProjectManager _instance = ProjectManager._();
  static ProjectManager get instance => _instance;

  final List<Project> _projects = [
    Project(
      name: 'Mobile Project',
      description: 'Describe',
      dueDate: '7/1/2569',
      status: 'Complete',
      progress: 65,
    ),
    Project(
      name: 'Nahi Clinic',
      description: 'Describe',
      dueDate: '7/1/2569',
      status: 'Complete',
      progress: 65,
    ),
  ];

  void addProject(Project project) {
    _projects.add(project);
  }

  List<Project> getAllProjects() {
    return List.unmodifiable(_projects);
  }
}
