import 'package:flutter/material.dart';
import '../widgets/add_task_bottom_sheet.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isTaskTab = true;
  final List<Map<String, String>> _addedTasks = [];
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
    setState(() {
      _addedTasks.insert(0, {
        'name': name,
        'description': description,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'priority': priority,
      });
    });
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
                              const Icon(Icons.more_vert, color: Colors.black),
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
            Container(
              height: 60,
              color: const Color(0xFFEBE4F5),
              child: Row(
                children: [
                  _navItem(Icons.dashboard, 'Home'),
                  _navItem(Icons.edit_note, 'Project'),
                  _navItem(Icons.bar_chart, 'Stats'),
                  _navItem(Icons.person_outline, 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
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
    );
  }

  Widget _buildTasksContent() {
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
          // Added tasks
          ..._addedTasks.map(
            (task) => _buildTaskCard(
              task['name'] ?? '',
              task['description'] ?? 'Description',
              'Doing',
            ),
          ),
          // Default tasks or empty state
          if (_isDefaultProject) ...[
            _buildTaskCard(
              'Mobile UI Design',
              'Figma design for mobile app',
              'Doing',
            ),
            _buildTaskCard('Dashboard API', 'REST API endpoints', 'Review'),
            _buildTaskCard(
              'Database Schema',
              'MongoDB schema design',
              'Complete',
            ),
          ] else if (_addedTasks.isEmpty) ...[
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'No tasks yet',
                style: TextStyle(color: Color(0xFF828282)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
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

  Widget _navItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF828282)),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF828282)),
          ),
        ],
      ),
    );
  }
}
