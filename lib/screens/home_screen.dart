import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/project_manager.dart';
import '../widgets/add_project_bottom_sheet.dart';
import '../widgets/invite_member_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

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
      onInvite: (email) {
        ProjectManager.instance.addProject(
          Project(
            name: name,
            description: description.isEmpty ? 'Describe' : description,
            dueDate: dueDate,
            memberEmail: email.isNotEmpty ? email : null,
          ),
        );
        _refreshProjects();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = ProjectManager.instance.getAllProjects();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'UniTask',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.notifications_none, size: 28, color: Colors.black),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
            ),
            const SizedBox(height: 8),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due date section
                    const Text(
                      'Due date',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Static due date card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dashboard API',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF888888),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Color(0xFF888888),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '7/1/2569',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: Color(0xFF888888),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '23:59',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Project section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Project',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/my-projects'),
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6750A4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Project list
                    ...projects.map((p) => _buildProjectCard(p)),
                  ],
                ),
              ),
            ),
            // Bottom navigation
            _buildBottomNav(),
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
          onPressed: _showAddProject,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/project-detail',
          arguments: {'name': project.name, 'email': project.memberEmail},
        );
      },
      child: Card(
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                project.description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 12),
              // Status tag
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
                      Icon(
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
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '5',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '1',
                        style: TextStyle(
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

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      color: const Color(0xFFEBE4F5),
      child: Row(
        children: [
          _navItem(Icons.dashboard, 'Home', 0),
          _navItem(
            Icons.edit_note,
            'Project',
            1,
            onTap: () {
              Navigator.pushNamed(context, '/my-projects');
            },
          ),
          _navItem(Icons.bar_chart, 'Stats', 2),
          _navItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final isActive = _selectedNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap:
            onTap ??
            () {
              setState(() => _selectedNavIndex = index);
            },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? Colors.black : const Color(0xFF828282),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.black : const Color(0xFF828282),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
