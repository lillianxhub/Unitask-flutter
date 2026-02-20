import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_manager.dart';
import '../models/task.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/task_detail_bottom_sheet.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isTaskTab = true;
  bool _isDefaultProject = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? 'Mobile Project';
    _isDefaultProject =
        projectName == 'Mobile Project' || projectName == 'Nahi Clinic';
  }

  void _onTaskAdded(
    String name,
    String description,
    String assignedTo,
    String dueDate,
    String priority,
  ) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? 'Mobile Project';

    DateTime parsedDueDate = DateTime.now();
    if (dueDate.isNotEmpty) {
      try {
        final parts = dueDate.split('/');
        if (parts.length == 3) {
          parsedDueDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        // use default
      }
    }

    final newTask = Task(
      title: name,
      description: description,
      dueDate: parsedDueDate,
      createdDate: DateTime.now(),
    );

    context.read<ProjectManager>().addTask(projectName, newTask);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? 'Mobile Project';
    final memberEmail = args?['email'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top nav
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                      color: Color(0xFF828282),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, color: Color(0xFF828282)),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  projectName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'Delete') {
                                    context
                                        .read<ProjectManager>()
                                        .deleteProject(projectName);
                                    Navigator.pop(context);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return {'Delete'}.map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(
                                        choice,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF828282),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Text(
                                '10 Task',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4F4F4F),
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Color(0xFF4F4F4F),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '4 members',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4F4F4F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Progress Bar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4F4F4F),
                                ),
                              ),
                              Text(
                                '65%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4F4F4F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.65,
                              backgroundColor: Color(0xFFE0E0E0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFCFBDF6),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isTaskTab = true),
                            child: Column(
                              children: [
                                Text(
                                  'Task',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _isTaskTab
                                        ? const Color(0xFF6750A4)
                                        : const Color(0xFF828282),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 50,
                                  height: 3,
                                  color: _isTaskTab
                                      ? const Color(0xFF6750A4)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () => setState(() => _isTaskTab = false),
                            child: Column(
                              children: [
                                Text(
                                  'Members',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: !_isTaskTab
                                        ? const Color(0xFF6750A4)
                                        : const Color(0xFF828282),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 50,
                                  height: 3,
                                  color: !_isTaskTab
                                      ? const Color(0xFF6750A4)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    // Tab content
                    if (_isTaskTab)
                      _buildTasksContent()
                    else
                      _buildMembersContent(memberEmail),
                  ],
                ),
              ),
            ),
            // Bottom nav
            BottomNav(
              currentIndex: 1, // Stay on "Project" tab
              onTap: (index) {
                if (index != 1) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                    arguments: {'tabIndex': index},
                  );
                } else {
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFCFBDF6), Color(0xFFFFC7C6)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCFBDF6).withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              AddTaskBottomSheet.show(context, onSave: _onTaskAdded);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksContent() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? 'Mobile Project';

    return Consumer<ProjectManager>(
      builder: (context, manager, child) {
        final project = manager.projects.firstWhere(
          (p) => p.name == projectName,
          orElse: () => manager.projects.first,
        );
        final tasks = project.tasks;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.sort, color: Colors.black),
                ],
              ),
              const SizedBox(height: 16),

              if (tasks.isEmpty) ...[
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'No tasks yet',
                    style: TextStyle(color: Color(0xFF828282)),
                  ),
                ),
                const SizedBox(height: 40),
              ] else ...[
                ...tasks.map(
                  (task) => GestureDetector(
                    onTap: () {
                      TaskDetailBottomSheet.show(context, task, () {
                        context.read<ProjectManager>().deleteTask(
                          projectName,
                          task,
                        );
                      });
                    },
                    child: _buildTaskCard(
                      task.title,
                      task.description.isEmpty
                          ? 'No description'
                          : task.description,
                      task.isCompleted ? 'Complete' : 'Doing',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(String title, String subtitle, String status) {
    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'Complete':
        statusColor = const Color(0xFF2E7D32);
        statusBg = const Color(0xFFE8F5E9);
        break;
      case 'Review':
        statusColor = const Color(0xFFE65100);
        statusBg = const Color(0xFFFFF3E0);
        break;
      default:
        statusColor = const Color(0xFF1565C0);
        statusBg = const Color(0xFFE3F2FD);
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 12, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Color(0xFF888888),
                ),
                const SizedBox(width: 4),
                const Text(
                  '7/1/2569',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
                const Spacer(),
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFCFBDF6),
                  child: Icon(Icons.person, size: 14, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersContent(String? memberEmail) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Members',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: const [
                    Icon(Icons.add, size: 16, color: Color(0xFF6750A4)),
                    SizedBox(width: 4),
                    Text(
                      'Invite',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6750A4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Owner
          _buildMemberCard('You (Owner)', 'admin@unitask.com', isOwner: true),
          const SizedBox(height: 12),
          // Members for default projects
          if (_isDefaultProject) ...[
            _buildMemberCard('Member 1', 'member1@gmail.com'),
            const SizedBox(height: 12),
            _buildMemberCard('Member 2', 'member2@gmail.com'),
          ] else if (memberEmail != null && memberEmail.isNotEmpty) ...[
            _buildMemberCard('Invited Member', memberEmail),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberCard(String name, String email, {bool isOwner = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isOwner
                ? const Color(0xFFCFBDF6)
                : const Color(0xFF888888),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(email, style: const TextStyle(color: Color(0xFF888888))),
              ],
            ),
          ),
          if (!isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Editor',
                style: TextStyle(fontSize: 12, color: Color(0xFFCFBDF6)),
              ),
            ),
        ],
      ),
    );
  }
}
