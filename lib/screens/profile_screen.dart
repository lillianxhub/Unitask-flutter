import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';
import '../models/project_manager.dart';
import '../models/locale_manager.dart';
import '../widgets/edit_profile_bottom_sheet.dart';
import '../screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final locale = context.watch<LocaleManager>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF2A2040), const Color(0xFF1E1830)]
                    : [const Color(0xFFEFE9F5), const Color(0xFFD6C6F2)],
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
                            border: Border.all(color: cs.onSurface, width: 3),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 50,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: cs.onSurface.withValues(alpha: 0.7),
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
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.t('details'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
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
                                cs.onSurface,
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
                        context,
                        Icons.edit_outlined,
                        locale.t('edit_profile'),
                        onTap: () {
                          EditProfileBottomSheet.show(context);
                        },
                      ),
                      _buildMenuItem(
                        context,
                        Icons.settings_outlined,
                        locale.t('account_settings'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        Icons.notifications_outlined,
                        locale.t('notifications'),
                        onTap: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),

                      const SizedBox(height: 20),

                      // Logout
                      Consumer<UserManager>(
                        builder: (context, userManager, child) =>
                            _buildMenuItem(
                              context,
                              Icons.logout,
                              locale.t('logout'),
                              color: const Color(0xFFFF8A80),
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      locale.t('logout_confirm_title'),
                                    ),
                                    content: Text(
                                      locale.t('logout_confirm_msg'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          locale.t('not_now'),
                                          style: TextStyle(
                                            color: cs.onSurface.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          locale.t('confirm'),
                                          style: TextStyle(
                                            color: Color(0xFFFF8A80),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await userManager.logout();
                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/welcome',
                                      (route) => false,
                                    );
                                  }
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
          style: TextStyle(
            fontSize: 14,
            color: color.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final itemColor = color ?? cs.onSurface;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: itemColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: itemColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: itemColor.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}
