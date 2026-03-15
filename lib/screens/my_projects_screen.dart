import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/project_manager.dart';
import '../models/task.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  int _selectedFilter = 0;
  int _currentTab = 0; // 0: Projects, 1: Tasks
  String _selectedPriority = 'All'; // Priority Filter
  final List<String> _filters = ['All', 'Doing', 'Complete', 'Out of Date'];
  double _s = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    _s = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.4).toDouble();
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(left: 20 * _s, top: 20 * _s, right: 20 * _s),
              child: Text(
                'My Dashboard',
                style: TextStyle(
                  fontSize: 28 * _s,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
            SizedBox(height: 16 * _s),
            // Overview Stats
            Consumer<ProjectManager>(
              builder: (context, manager, child) {
                return _buildOverviewStats(manager.projects, cs);
              },
            ),
            SizedBox(height: 16 * _s),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 18 * _s),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  String title = _filters[index];
                  IconData icon = Icons.apps_rounded;
                  Color iconColor = cs.primary;

                  if (index == 1) {
                    icon = Icons.hourglass_top_rounded;
                    iconColor = Colors.orange;
                  } else if (index == 2) {
                    icon = Icons.check_circle_outline_rounded;
                    iconColor = Colors.green;
                  } else if (index == 3) {
                    icon = Icons.warning_amber_rounded;
                    iconColor = Colors.red;
                  }
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 12 * _s),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100 * _s,
                        padding: EdgeInsets.all(12 * _s),
                        decoration: BoxDecoration(
                          color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? iconColor : cs.outline.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, color: iconColor, size: 24 * _s),
                            SizedBox(height: 8 * _s),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13 * _s,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16 * _s),
            // Segmented Control & Priority Dropdown
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * _s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSegmentedControl(cs),
                  _buildPriorityDropdown(cs),
                ],
              ),
            ),
            SizedBox(height: 16 * _s),
            Divider(height: 1, color: cs.outline),
            Expanded(
              child: Consumer<ProjectManager>(
                builder: (context, manager, child) {
                  final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'guest@unitask.com';
                  var projects = manager.projects;
                  
                  // Filter out "Out of Date" visually since it's hard to parse string dates robustly here
                  // We'll focus on All, Doing, Complete

                  if (_currentTab == 0) {
                    // --- PROJECTS VIEW ---
                    if (_selectedPriority != 'All') {
                      projects = projects.where((p) => p.tasks.any((t) => t.priority == _selectedPriority && !t.isCompleted)).toList();
                    }

                    if (_selectedFilter == 1) { // Doing
                      projects = projects.where((p) => p.status != 'Complete').toList();
                    } else if (_selectedFilter == 2) { // Complete
                      projects = projects.where((p) => p.status == 'Complete').toList();
                    } else if (_selectedFilter == 3) { // Out of Date
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      projects = projects.where((p) {
                        if (p.status == 'Complete') return false;
                        final pDate = _parseDateString(p.dueDate);
                        if (pDate == null) return false;
                        return pDate.isBefore(today);
                      }).toList();
                    }

                    if (projects.isEmpty) {
                      return _buildEmptyState('No projects found.');
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 20 * _s, top: 8 * _s),
                      itemCount: projects.length,
                      itemBuilder: (context, index) => _buildProjectCard(projects[index], userEmail),
                    );
                  } else {
                    // --- TASKS VIEW ---
                    List<Map<String, dynamic>> myTasks = [];
                    for (var project in projects) {
                      for (var task in project.tasks) {
                        bool isAssigned = task.assignedTo.contains(userEmail);
                        
                        if (isAssigned) {
                          myTasks.add({'task': task, 'project': project});
                        }
                      }
                    }

                    if (_selectedPriority != 'All') {
                      myTasks = myTasks.where((t) => (t['task'] as Task).priority == _selectedPriority).toList();
                    }

                    if (_selectedFilter == 1) { // Doing
                      myTasks = myTasks.where((t) => !(t['task'] as Task).isCompleted).toList();
                    } else if (_selectedFilter == 2) { // Complete
                      myTasks = myTasks.where((t) => (t['task'] as Task).isCompleted).toList();
                    } else if (_selectedFilter == 3) { // Out of Date
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      myTasks = myTasks.where((t) {
                        final task = t['task'] as Task;
                        if (task.isCompleted) return false;
                        final dueDate = task.dueDate;
                        final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
                        return taskDate.isBefore(today);
                      }).toList();
                    }

                    if (myTasks.isEmpty) {
                      return _buildEmptyState('No tasks found.');
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 20 * _s, top: 8 * _s),
                      itemCount: myTasks.length,
                      itemBuilder: (context, index) => _buildTaskCard(
                        myTasks[index]['task'] as Task, 
                        myTasks[index]['project'] as Project,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
        bgColor = const Color(0xFFFFF3E0); // Orange light
        textColor = const Color(0xFFE65100); // Orange dark
        break;
      case 'pending':
      case 'todo':
        bgColor = const Color(0xFFE3F2FD); // Blue light
        textColor = const Color(0xFF1565C0); // Blue dark
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF757575);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * _s, vertical: 4 * _s),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12 * _s,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, String userEmail) {
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
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 20 * _s, vertical: 10 * _s),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(20 * _s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 20 * _s,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20 * _s,
                    color: cs.onSurface,
                  ),
                ],
              ),
              SizedBox(height: 4 * _s),
              Text(
                project.description,
                style: TextStyle(fontSize: 14 * _s, color: Color(0xFF888888)),
              ),
              SizedBox(height: 12 * _s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildStatusPill(project.status),
                      _buildPriorityCountBadge(project, userEmail),
                    ],
                  ),
                  Text(
                    '${project.progress}%',
                    style: TextStyle(
                      fontSize: 14 * _s,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * _s),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: project.progress / 100,
                  backgroundColor: cs.outline,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  minHeight: 8 * _s,
                ),
              ),
              SizedBox(height: 16 * _s),
              Divider(height: 1, color: cs.outline),
              SizedBox(height: 12 * _s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16 * _s,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: 6 * _s),
                      Text(
                        'Due Date : ${project.dueDate}',
                        style: TextStyle(
                          fontSize: 12 * _s,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16 * _s,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: 4 * _s),
                      Text(
                        '${project.comments.length}',
                        style: TextStyle(
                          fontSize: 12 * _s,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(width: 12 * _s),
                      Icon(
                        Icons.attach_file,
                        size: 16 * _s,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: 4 * _s),
                      Text(
                        '${project.tasks.length}',
                        style: TextStyle(
                          fontSize: 12 * _s,
                          color: cs.onSurface.withValues(alpha: 0.5),
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

  Widget _buildPriorityCountBadge(Project project, String userEmail) {
    List<String> prioritiesToCheck = _selectedPriority == 'All'
        ? ['High', 'Medium', 'Low']
        : [_selectedPriority];

    List<Widget> badges = [];
    final bool isOwner = userEmail == project.ownerEmail;

    for (String priority in prioritiesToCheck) {
      int count;
      if (isOwner) {
        // Owner sees overall project picture
        count = project.tasks
            .where((t) => t.priority == priority && !t.isCompleted)
            .length;
      } else {
        // Member sees only their personal assigned work
        count = project.tasks
            .where((t) =>
                t.priority == priority &&
                t.assignedTo.contains(userEmail) &&
                !t.completedBy.contains(userEmail))
            .length;
      }
      
      if (count > 0) {
        Color color;
        switch (priority.toLowerCase()) {
          case 'high':
            color = Colors.red;
            break;
          case 'medium':
            color = Colors.purple;
            break;
          case 'low':
            color = Colors.blue;
            break;
          default:
            color = Colors.grey;
        }

        badges.add(
          Container(
            margin: EdgeInsets.only(left: 8 * _s),
            padding: EdgeInsets.symmetric(horizontal: 10 * _s, vertical: 4 * _s),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12 * _s,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        );
      }
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: badges,
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * _s),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16 * _s,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.all(4 * _s),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentButton('Projects', 0, cs),
          _buildSegmentButton('Task', 1, cs),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index, ColorScheme cs) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 24 * _s, vertical: 10 * _s),
        decoration: BoxDecoration(
          color: isSelected ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14 * _s,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStats(List<Project> allProjects, ColorScheme cs) {
    int total = 0;
    int doing = 0;
    int done = 0;

    if (_currentTab == 0) {
      // Projects stats
      total = allProjects.length;
      doing = allProjects.where((p) => p.status != 'Complete').length;
      done = allProjects.where((p) => p.status == 'Complete').length;
    } else {
      // Tasks stats for current user
      final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'guest@unitask.com';
      for (var p in allProjects) {
        for (var t in p.tasks) {
          bool isAssigned = t.assignedTo.contains(userEmail);

          if (isAssigned) {
            total++;
            if (t.isCompleted) {
              done++;
            } else {
              doing++;
            }
          }
        }
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * _s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('Total', total.toString(), cs.primary, cs),
          _buildStatItem('Doing', doing.toString(), Colors.orange, cs),
          _buildStatItem('Done', done.toString(), Colors.green, cs),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color, ColorScheme cs) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4 * _s),
        padding: EdgeInsets.symmetric(vertical: 16 * _s),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24 * _s,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 4 * _s),
            Text(
              label,
              style: TextStyle(
                fontSize: 12 * _s,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, Project project) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        // Show task detail
        Navigator.pushNamed(
          context,
          '/project-detail',
          arguments: {'name': project.name},
        );
      },
      child: Card(
        color: cs.surface,
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 20 * _s, vertical: 8 * _s),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16 * _s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16 * _s,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * _s, vertical: 4 * _s),
                    decoration: BoxDecoration(
                      color: task.isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.isCompleted ? 'Done' : 'Doing',
                      style: TextStyle(
                        fontSize: 12 * _s,
                        fontWeight: FontWeight.bold,
                        color: task.isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * _s),
                  _buildPriorityBadge(task.priority),
                ],
              ),
              SizedBox(height: 8 * _s),
              Row(
                children: [
                  Icon(Icons.folder_outlined, size: 14 * _s, color: cs.primary.withValues(alpha: 0.7)),
                  SizedBox(width: 4 * _s),
                  Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 12 * _s,
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 12 * _s),
                  _buildDueDateUX(task.dueDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateUX(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    Color color;
    String text;
    FontWeight weight = FontWeight.bold;
    IconData icon = Icons.calendar_today;

    if (taskDate.isBefore(today)) {
      final daysOverdue = today.difference(taskDate).inDays;
      color = Colors.red;
      text = 'Overdue by $daysOverdue day(s)';
      icon = Icons.warning_amber_rounded;
    } else if (taskDate.isAtSameMomentAs(today)) {
      color = Colors.pink;
      text = 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      color = Colors.cyan.shade700;
      text = 'Tomorrow';
    } else {
      color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
      text = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
      weight = FontWeight.normal;
    }

    return Row(
      children: [
        Icon(icon, size: 14 * _s, color: color),
        SizedBox(width: 4 * _s),
        Text(
          text,
          style: TextStyle(
            fontSize: 12 * _s,
            color: color,
            fontWeight: weight,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.purple;
        break;
      case 'low':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * _s, vertical: 4 * _s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11 * _s,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown(ColorScheme cs) {
    return Container(
      height: 36 * _s,
      padding: EdgeInsets.symmetric(horizontal: 12 * _s),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPriority,
          icon: Icon(Icons.keyboard_arrow_down, size: 20 * _s, color: cs.primary),
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            fontSize: 13 * _s,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPriority = newValue;
              });
            }
          },
          items: <String>['All', 'High', 'Medium', 'Low']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  DateTime? _parseDateString(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      debugPrint("Error parsing project date: $dateStr");
    }
    return null;
  }
}
