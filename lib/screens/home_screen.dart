import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/project_manager.dart';
import '../models/task.dart';
import '../widgets/add_project_bottom_sheet.dart';
import '../widgets/invite_member_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refreshProjects() {
    setState(() {});
  }

  void _showAddProject() {
    AddProjectBottomSheet.show(
      context,
      onSave: (name, description, dueDate) {
        _showInviteMember(name, description, dueDate);
      },
    );
  }

  void _showInviteMember(String name, String description, String dueDate) {
    InviteMemberBottomSheet.show(
      context,
      onInvite: (email, role) {
        final currentUser = FirebaseAuth.instance.currentUser;
        final userManager = context.read<UserManager>();
        ProjectManager.instance.addProject(
          Project(
            name: name,
            description: description.isEmpty ? 'Describe' : description,
            dueDate: dueDate,
            ownerId: currentUser?.uid ?? 'guest',
            ownerName: userManager.name.isNotEmpty
                ? userManager.name
                : 'Project Owner',
            ownerEmail: userManager.email.isNotEmpty
                ? userManager.email
                : 'owner@unitask.com',
            members: email.isNotEmpty ? [email] : [],
            memberRoles: email.isNotEmpty ? {email: role} : {},
          ),
        );
        _refreshProjects();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<ProjectManager>(
                builder: (context, manager, child) {
                  final projects = manager.projects;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDueDateHeader(),
                        const SizedBox(height: 16),
                        _buildUpcomingTasksList(projects),
                        const SizedBox(height: 28),
                        _buildProjectSectionHeader(),
                        const SizedBox(height: 8),
                        Column(
                          children: projects
                              .map((p) => _buildProjectCard(p))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UniTask',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Consumer<UserManager>(
                builder: (context, user, child) {
                  return Text(
                    'สวัสดี, ${user.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6750A4),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          Consumer<ProjectManager>(
            builder: (context, manager, child) {
              final unreadCount = manager.unreadNotificationsCount;
              final userEmail = FirebaseAuth.instance.currentUser?.email;
              final hasPending = manager.projects.any(
                (p) => p.pendingMembers.contains(userEmail),
              );
              final hasNotifications = unreadCount > 0 || hasPending;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    color: Colors.black,
                  ),
                  if (hasNotifications)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            SizedBox(width: 16),
            Icon(Icons.search, color: Color(0xFFBDBDBD)),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDateHeader() {
    return const Text(
      'Upcoming',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildUpcomingTasksList(List<Project> projects) {
    // 1. Extract all incomplete tasks
    List<Map<String, dynamic>> allTasks = [];
    for (var project in projects) {
      for (var task in project.tasks) {
        if (!task.isCompleted) {
          allTasks.add({'task': task, 'project': project});
        }
      }
    }

    // 2. Sort by due date (ascending)
    allTasks.sort((a, b) {
      final Task taskA = a['task'];
      final Task taskB = b['task'];
      return taskA.dueDate.compareTo(taskB.dueDate);
    });

    if (allTasks.isEmpty) {
      // Empty State
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: const [
            Icon(Icons.coffee_outlined, size: 48, color: Color(0xFFBDBDBD)),
            SizedBox(height: 12),
            Text(
              'ตอนนี้ไม่มีงานด่วน ไปพักผ่อนได้เลย!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Limit to top 3 urgent tasks
    final int displayCount = allTasks.length > 3 ? 3 : allTasks.length;
    final urgentTasks = allTasks.sublist(0, displayCount);

    return Column(
      children: urgentTasks.map((t) {
        return _buildUrgentTaskCard(t['task'] as Task, t['project'] as Project);
      }).toList(),
    );
  }

  Widget _buildUrgentTaskCard(Task task, Project project) {
    final now = DateTime.now();
    // Consider overdue if due date is before today (ignoring time for simplicity)
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );
    final isOverdue = due.isBefore(today);

    final num daysDiff = due.difference(today).inDays;
    String dueText;
    if (isOverdue) {
      dueText = 'Overdue by ${-daysDiff} day(s)';
    } else if (daysDiff == 0) {
      dueText = 'Today';
    } else if (daysDiff == 1) {
      dueText = 'Tomorrow';
    } else {
      dueText =
          '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}';
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/project-detail',
          arguments: {'name': project.name},
        );
      },
      child: Card(
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
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isOverdue ? Colors.red : const Color(0xFF888888),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dueText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isOverdue
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isOverdue ? Colors.red : const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Project',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/my-projects'),
          child: const Text(
            'See All',
            style: TextStyle(fontSize: 16, color: Color(0xFF6750A4)),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Project project) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/project-detail',
          arguments: {'name': project.name},
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                project.description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  project.status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due Date : ${project.dueDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${project.comments.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.attach_file,
                        size: 16,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${project.tasks.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Floating Action Button ---

  Widget _buildFAB() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCFBDF6), Color(0xFFFFC7C6)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCFBDF6).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showAddProject,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
