import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/project_manager.dart';
import '../models/user_manager.dart';
import '../models/task.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/task_detail_bottom_sheet.dart';
import '../widgets/invite_member_bottom_sheet.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _tabIndex = 0; // 0 = Task, 1 = Detail, 2 = Members
  Map<String, String> _memberNamesMap = {};
  bool _isLoadingMembers = true;
  String _currentProjectName = '';
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? '';
    if (projectName != _currentProjectName) {
      _currentProjectName = projectName;
      _fetchMemberNames(projectName);
    }
  }

  Future<void> _fetchMemberNames(String projectName) async {
    if (projectName.isEmpty) return;
    try {
      final project = context.read<ProjectManager>().projects.firstWhere(
        (p) => p.name == projectName,
        orElse: () =>
            Project(name: '', description: '', dueDate: '', ownerId: ''),
      );

      if (project.members.isEmpty) {
        if (mounted) setState(() => _isLoadingMembers = false);
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'email',
            whereIn: project.members.take(30).toList(),
          ) // Firestore 'in' limit
          .get();

      final Map<String, String> namesMap = {};
      for (var doc in querySnapshot.docs) {
        final email = doc.data()['email'] as String?;
        final name = doc.data()['name'] as String?;
        if (email != null && name != null) {
          namesMap[email] = name;
        }
      }

      if (mounted) {
        setState(() {
          _memberNamesMap = namesMap;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
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
      assignedTo: assignedTo.isNotEmpty ? assignedTo : null,
      priority: priority,
    );

    context.read<ProjectManager>().addTask(projectName, newTask);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? 'Mobile Project';

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
                      child: Consumer<ProjectManager>(
                        builder: (context, manager, child) {
                          final project = manager.projects.firstWhere(
                            (p) => p.name == projectName,
                            orElse: () => manager.projects.first,
                          );
                          final taskCount = project.tasks.length;
                          final memberCount = project.members.length;
                          // In the original, the owner is not always in the 'members' array, so let's check
                          final totalMembers = memberCount > 0
                              ? memberCount
                              : 1;
                          final progress = project.progress;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      project.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (project.ownerId ==
                                          (FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.uid ??
                                              'guest') ||
                                      FirebaseAuth
                                              .instance
                                              .currentUser
                                              ?.email ==
                                          project.ownerId)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'Delete') {
                                          context
                                              .read<ProjectManager>()
                                              .deleteProject(project.name);
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/home',
                                            (route) => false,
                                            arguments: {'tabIndex': 0},
                                          );
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
                              Text(
                                project.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF828282),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '$taskCount Task${taskCount == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4F4F4F),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Color(0xFF4F4F4F),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$totalMembers member${totalMembers == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4F4F4F),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Progress Bar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4F4F4F),
                                    ),
                                  ),
                                  Text(
                                    '$progress%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4F4F4F),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFCFBDF6),
                                      ),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _tabIndex = 0),
                            child: Column(
                              children: [
                                Text(
                                  'Task',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _tabIndex == 0
                                        ? const Color(0xFF6750A4)
                                        : const Color(0xFF828282),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 50,
                                  height: 3,
                                  color: _tabIndex == 0
                                      ? const Color(0xFF6750A4)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () => setState(() => _tabIndex = 1),
                            child: Column(
                              children: [
                                Text(
                                  'Detail',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _tabIndex == 1
                                        ? const Color(0xFF6750A4)
                                        : const Color(0xFF828282),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 50,
                                  height: 3,
                                  color: _tabIndex == 1
                                      ? const Color(0xFF6750A4)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () => setState(() => _tabIndex = 2),
                            child: Column(
                              children: [
                                Text(
                                  'Members',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _tabIndex == 2
                                        ? const Color(0xFF6750A4)
                                        : const Color(0xFF828282),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 50,
                                  height: 3,
                                  color: _tabIndex == 2
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
                    if (_tabIndex == 0)
                      _buildTasksContent()
                    else if (_tabIndex == 1)
                      _buildDetailContent(context, projectName)
                    else
                      _buildMembersContent(context, projectName),
                  ],
                ),
              ),
            ),
            // Comment input
            if (_tabIndex == 1)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Color(0xFF828282), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'เขียนความคิดเห็น...',
                          hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        final text = _commentController.text.trim();
                        if (text.isNotEmpty) {
                          final userManager = context.read<UserManager>();
                          final projectManager = context.read<ProjectManager>();
                          final project = projectManager.projects.firstWhere(
                            (p) => p.name == projectName,
                            orElse: () => Project(
                              name: projectName,
                              description: '',
                              dueDate: '',
                              ownerId: '',
                            ),
                          );
                          final comment = Comment(
                            id: UniqueKey().toString(),
                            authorEmail: userManager.email,
                            authorName: userManager.name,
                            text: text,
                            timestamp: DateTime.now(),
                          );
                          projectManager.addComment(project.name, comment);
                          _commentController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCFBDF6), Color(0xFFFFC7C6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
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
      floatingActionButton: Consumer<ProjectManager>(
        builder: (context, manager, child) {
          final project = manager.projects.firstWhere(
            (p) => p.name == projectName,
            orElse: () => manager.projects.first,
          );
          final userEmail =
              FirebaseAuth.instance.currentUser?.email ?? 'guest@unitask.com';
          final userRole =
              project.memberRoles[userEmail] ??
              (userEmail == project.ownerId ? 'Owner' : 'Editor');
          final canEdit = userRole == 'Owner' || userRole == 'Editor';

          if (_tabIndex != 0 || !canEdit) return const SizedBox.shrink();

          return Padding(
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
                  AddTaskBottomSheet.show(
                    context,
                    members: project.members,
                    onSave: _onTaskAdded,
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, String projectName) {
    return Consumer<ProjectManager>(
      builder: (context, manager, child) {
        final project = manager.projects.firstWhere(
          (p) => p.name == projectName,
          orElse: () => Project(
            name: projectName,
            description: '',
            dueDate: '',
            ownerId: '',
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detail section
              const Text(
                'Detail',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow(
                'ผู้รับผิดชอบ',
                _isLoadingMembers
                    ? 'กำลังโหลด...'
                    : _memberNamesMap.values.join(', '),
              ),
              const SizedBox(height: 16),
              _detailRow('วันครบกำหนด', project.dueDate),
              const SizedBox(height: 16),
              _detailRow('สถานะ', project.status),
              const SizedBox(height: 32),
              // Comment section
              const Text(
                'Comment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              if (project.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'ยังไม่มีความคิดเห็น',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                )
              else
                ...project.comments.map(
                  (comment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _commentItem(comment),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }

  Widget _commentItem(Comment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFCFBDF6),
          child: Text(
            comment.authorName.isNotEmpty
                ? comment.authorName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
                style: const TextStyle(color: Color(0xFF4F4F4F)),
              ),
            ],
          ),
        ),
      ],
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

        final userEmail =
            FirebaseAuth.instance.currentUser?.email ?? 'guest@unitask.com';
        final userRole =
            project.memberRoles[userEmail] ??
            (userEmail == project.ownerId ? 'Owner' : 'Editor');
        final canEdit = userRole == 'Owner' || userRole == 'Editor';

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
                      TaskDetailBottomSheet.show(
                        context,
                        task,
                        canEdit: canEdit,
                        onDelete: canEdit
                            ? () {
                                context.read<ProjectManager>().deleteTask(
                                  projectName,
                                  task,
                                );
                              }
                            : null,
                        onUpdate: canEdit
                            ? (updatedTask) {
                                context.read<ProjectManager>().updateTask(
                                  projectName,
                                  task,
                                  updatedTask,
                                );
                              }
                            : null,
                        onComment: canEdit
                            ? (commentText) {
                                final userManager = context.read<UserManager>();
                                final newComment = Comment(
                                  id: UniqueKey().toString(),
                                  authorEmail: userManager.email,
                                  authorName: userManager.name,
                                  text: commentText,
                                  timestamp: DateTime.now(),
                                );
                                context.read<ProjectManager>().addTaskComment(
                                  projectName,
                                  task,
                                  newComment,
                                );
                              }
                            : null,
                      );
                    },
                    child: _buildTaskCard(task),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    String title = task.title;
    String subtitle = task.description.isEmpty
        ? 'No description'
        : task.description;
    String status = task.isCompleted ? 'Complete' : 'Doing';
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

    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.blue;
        break;
      default:
        priorityColor = Colors.orange;
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
                Text(
                  '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const Spacer(),
                if (task.priority.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: priorityColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      task.priority,
                      style: TextStyle(
                        fontSize: 10,
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (task.assignedTo != null && task.assignedTo!.isNotEmpty)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFCFBDF6),
                    child: Text(
                      task.assignedTo![0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 14, color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersContent(BuildContext context, String projectName) {
    return Consumer<ProjectManager>(
      builder: (context, manager, child) {
        final project = manager.projects.firstWhere(
          (p) => p.name == projectName,
          orElse: () => manager.projects.first,
        );

        final userEmail =
            FirebaseAuth.instance.currentUser?.email ?? 'guest@unitask.com';
        final userRole =
            project.memberRoles[userEmail] ??
            (userEmail == project.ownerId ? 'Owner' : 'Editor');
        final canEdit = userRole == 'Owner' || userRole == 'Editor';

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
                  if (canEdit)
                    GestureDetector(
                      onTap: () {
                        InviteMemberBottomSheet.show(
                          context,
                          onInvite: (email, role) {
                            if (email != null && email.isNotEmpty) {
                              context.read<ProjectManager>().inviteMember(
                                projectName,
                                email,
                                role,
                              );
                            }
                          },
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.add, size: 16, color: Color(0xFF6750A4)),
                          SizedBox(width: 4),
                          Text(
                            'Invite',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6750A4),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Owner
              _buildMemberCard(
                project.ownerName.isNotEmpty
                    ? '${project.ownerName} (Owner)'
                    : 'Project Owner',
                project.ownerEmail.isNotEmpty
                    ? project.ownerEmail
                    : project.ownerId,
                isOwner: true,
                roleLabel: 'Owner',
              ),
              const SizedBox(height: 12),

              // Dynamic Members
              ...project.members
                  .where((email) {
                    if (project.ownerEmail.isNotEmpty) {
                      return email != project.ownerEmail;
                    }
                    // Fallback for old projects: hide the one with 'Owner' role
                    return project.memberRoles[email] != 'Owner';
                  })
                  .map(
                    (email) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMemberCard(
                        _isLoadingMembers
                            ? 'Loading...'
                            : (_memberNamesMap[email] ?? 'Project Member'),
                        email,
                        roleLabel: project.memberRoles[email] ?? 'Editor',
                        canEditRole:
                            project.ownerId ==
                                FirebaseAuth.instance.currentUser?.uid ||
                            project.ownerEmail == userEmail,
                        onRoleChanged: (newRole) {
                          context.read<ProjectManager>().updateMemberRole(
                            projectName,
                            email,
                            newRole,
                          );
                        },
                        onRemove:
                            project.ownerId ==
                                    FirebaseAuth.instance.currentUser?.uid ||
                                project.ownerEmail == userEmail
                            ? () {
                                _confirmRemoveMember(
                                  context,
                                  projectName,
                                  email,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRemoveMember(
    BuildContext context,
    String projectName,
    String email,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove $email from this project?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<ProjectManager>().removeMember(projectName, email);
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    String name,
    String email, {
    bool isOwner = false,
    String roleLabel = 'Editor',
    bool canEditRole = false,
    ValueChanged<String>? onRoleChanged,
    VoidCallback? onRemove,
  }) {
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
          if (!isOwner) ...[
            if (canEditRole)
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: roleLabel,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Color(0xFF6750A4),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4),
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null &&
                          onRoleChanged != null &&
                          newValue != roleLabel) {
                        onRoleChanged(newValue);
                      }
                    },
                    items: <String>['Editor', 'Viewer']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  roleLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6750A4),
                  ),
                ),
              ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ],
      ),
    );
  }
}
