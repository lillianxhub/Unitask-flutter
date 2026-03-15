import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_manager.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, color: cs.onSurface),
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // balance the back icon
                ],
              ),
            ),
            // Invites list
            Expanded(
              child: Consumer<ProjectManager>(
                builder: (context, manager, child) {
                  // Get pending projects directly from manager
                  final pendingProjects = manager.pendingProjects;

                  // Get unread notifications
                  final unreadNotifications = manager.notifications
                      .where((n) => !n.isRead)
                      .toList();

                  if (pendingProjects.isEmpty && unreadNotifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No new notifications.',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (pendingProjects.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Invites',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        ...pendingProjects.map(
                          (project) => _buildInviteCard(context, project),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (unreadNotifications.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Activity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        ...unreadNotifications.map(
                          (notif) => _buildNotificationCard(context, notif),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Find the invite notification for this project to get the sender name
  String _getInviterName(ProjectManager manager, dynamic project) {
    try {
      final inviteNotif = manager.notifications.firstWhere(
        (n) => n.type == 'invite' && n.projectId == project.id,
      );
      return inviteNotif.senderName;
    } catch (_) {
      // Fallback: use ownerName from the project itself
      return (project.ownerName as String?)?.isNotEmpty == true
          ? project.ownerName
          : 'Someone';
    }
  }

  Widget _buildInviteCard(BuildContext context, dynamic project) {
    final cs = Theme.of(context).colorScheme;
    final manager = context.read<ProjectManager>();
    final inviterName = _getInviterName(manager, project);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.secondary,
                child: Text(
                  inviterName.isNotEmpty
                      ? inviterName[0].toUpperCase()
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
                      'Project Invitation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: inviterName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' invited you to join '),
                          TextSpan(
                            text: '"${project.name}"',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (project.id != null) {
                    context.read<ProjectManager>().rejectInvite(project.id!);
                  }
                },
                child: const Text(
                  'Decline',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (project.id != null) {
                    context.read<ProjectManager>().acceptInvite(project.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Joined ${project.name}'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Accept',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get the icon and color for each notification type
  ({IconData icon, Color color}) _notifStyle(String type, ColorScheme cs) {
    return switch (type) {
      'invite'         => (icon: Icons.mail_outline, color: cs.secondary),
      'accept'         => (icon: Icons.check_circle_outline, color: Colors.green),
      'reject'         => (icon: Icons.cancel_outlined, color: Colors.redAccent),
      'task'           => (icon: Icons.add_task, color: Colors.blue),
      'task_assigned'  => (icon: Icons.assignment_ind, color: Colors.orange),
      'task_completed' => (icon: Icons.task_alt, color: Colors.green),
      'comment'        => (icon: Icons.comment_outlined, color: cs.secondary),
      'removed'        => (icon: Icons.person_remove_outlined, color: Colors.redAccent),
      'role_changed'   => (icon: Icons.swap_horiz, color: Colors.purple),
      _                => (icon: Icons.notifications_outlined, color: cs.secondary),
    };
  }

  /// Get the action text describing what happened
  String _notifActionText(AppNotification notif) {
    return switch (notif.type) {
      'invite'         => ' invited you to join ',
      'accept'         => ' accepted the invitation to ',
      'reject'         => ' declined the invitation to ',
      'task'           => ' added a task to ',
      'task_assigned'  => ' assigned a task to you in ',
      'task_completed' => ' completed a task in ',
      'comment'        => ' commented on ',
      'removed'        => ' removed you from ',
      'role_changed'   => ' changed your role in ',
      _                => ' updated ',
    };
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notif) {
    final cs = Theme.of(context).colorScheme;
    final style = _notifStyle(notif.type, cs);

    return GestureDetector(
      onTap: () {
        context.read<ProjectManager>().markNotificationAsRead(notif.id);
        Navigator.pushNamed(
          context,
          '/project-detail',
          arguments: {'name': notif.projectName},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: style.color,
              child: Icon(style.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: cs.onSurface),
                      children: [
                        TextSpan(
                          text: notif.senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: _notifActionText(notif)),
                        TextSpan(
                          text: notif.projectName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (notif.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '"${notif.text}"',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
