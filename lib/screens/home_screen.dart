import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/project_manager.dart';
import '../models/task.dart';
import '../widgets/add_project_bottom_sheet.dart';
import '../widgets/invite_member_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';
import '../models/locale_manager.dart';
import '../widgets/app_floating_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            members: [],
            pendingMembers: (email != null && email.isNotEmpty) ? [email] : [],
            memberRoles: (email != null && email.isNotEmpty)
                ? {email: role}
                : {},
          ),
        );
        _refreshProjects();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch locale so the widget rebuilds when language changes
    context.watch<LocaleManager>();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  if (_searchQuery.isNotEmpty) {
                    return _buildSearchResults(projects);
                  }
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
      floatingActionButton: AppFloatingActionButton(onPressed: _showAddProject),
    );
  }

  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UniTask',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              Consumer<UserManager>(
                builder: (context, user, child) {
                  return Text(
                    '${LocaleManager.instance.t('hello')}, ${user.name}',
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.primary,
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
              final hasPending = manager.pendingProjects.isNotEmpty;
              final hasNotifications = unreadCount > 0 || hasPending;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: cs.onSurface),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: LocaleManager.instance.t('search_hint'),
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: cs.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            else
              const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Project> projects) {
    final cs = Theme.of(context).colorScheme;

    // Filter projects by name or description
    final matchedProjects = projects.where((p) {
      return p.name.toLowerCase().contains(_searchQuery) ||
          p.description.toLowerCase().contains(_searchQuery);
    }).toList();

    // Filter tasks by title or description, keeping reference to parent project
    final List<Map<String, dynamic>> matchedTasks = [];
    for (var project in projects) {
      for (var task in project.tasks) {
        if (task.title.toLowerCase().contains(_searchQuery) ||
            task.description.toLowerCase().contains(_searchQuery)) {
          matchedTasks.add({'task': task, 'project': project});
        }
      }
    }

    final hasResults = matchedProjects.isNotEmpty || matchedTasks.isNotEmpty;

    if (!hasResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: cs.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                '${LocaleManager.instance.t('no_results_for')} "${_searchController.text}"',
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LocaleManager.instance.t('try_other_keyword'),
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Projects section
          if (matchedProjects.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.folder_outlined, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Projects (${matchedProjects.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...matchedProjects.map((p) => _buildProjectCard(p)),
            const SizedBox(height: 20),
          ],
          // Tasks section
          if (matchedTasks.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.task_alt_outlined, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Tasks (${matchedTasks.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...matchedTasks.map(
              (t) => _buildSearchTaskCard(
                t['task'] as Task,
                t['project'] as Project,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchTaskCard(Task task, Project project) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/project-detail',
          arguments: {'name': project.name},
        );
      },
      child: Card(
        color: cs.surface,
        surfaceTintColor: cs.surface,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: task.isCompleted ? Colors.green : cs.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  _buildPriorityBadge(task.priority),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: cs.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDueDateHeader() {
    final cs = Theme.of(context).colorScheme;
    return Text(
      'Upcoming',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
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
      final cs = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          children: [
            Icon(
              Icons.coffee_outlined,
              size: 48,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              LocaleManager.instance.t('no_urgent_tasks'),
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: 0.5),
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
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Project',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
              arguments: {'tabIndex': 1},
            );
          },
          child: Text(
            'See All',
            style: TextStyle(fontSize: 16, color: cs.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'complete':
      case 'completed':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'doing':
      case 'in progress':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case 'pending':
      case 'todo':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF757575);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
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
          arguments: {'name': project.name},
        );
      },
      child: Card(
        color: Theme.of(context).cardTheme.color,
        surfaceTintColor: Theme.of(context).cardTheme.color,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusPill(project.status),
                  Text(
                    '${project.progress}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: project.progress / 100,
                  backgroundColor: Theme.of(context).colorScheme.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Theme.of(context).colorScheme.outline),
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
}
