import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';
import '../models/project_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 40,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEFE9F5), Color(0xFFD6C6F2)],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Consumer<UserManager>(
                  builder: (context, user, child) {
                    return Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 50,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'รายละเอียด',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Stats Row
                      Consumer<ProjectManager>(
                        builder: (context, projectManager, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                '${projectManager.totalProjectCount}',
                                'Project',
                                Colors.black,
                              ),
                              _buildStatItem(
                                '${projectManager.totalCompletedTaskCount}',
                                'Complete',
                                const Color(0xFF4CAF50),
                              ),
                              _buildStatItem(
                                '${projectManager.totalDoingTaskCount}',
                                'Doing',
                                const Color(0xFF81D4FA),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // Menu Items
                      _buildMenuItem(
                        Icons.edit_outlined,
                        'แก้ไขข้อมูลส่วนตัว',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.settings_outlined,
                        'ตั้งค่าบัญชี',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        Icons.notifications_outlined,
                        'การแจ้งเตือน',
                        onTap: () {},
                      ),

                      const SizedBox(height: 20),

                      // Logout
                      Consumer<UserManager>(
                        builder: (context, userManager, child) =>
                            _buildMenuItem(
                              Icons.logout,
                              'ออกจากระบบ',
                              color: const Color(0xFFFF8A80),
                              onTap: () async {
                                await userManager.logout();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/welcome',
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Color color = Colors.black,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}
