import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_manager.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'สรุปผลและสถิติ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert, color: cs.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ภาพรวมการทำงานของคุณ',
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),

              // Overview Cards
              Consumer<ProjectManager>(
                builder: (context, manager, child) {
                  return Row(
                    children: [
                      // Success Rate Card
                      Expanded(
                        child: Container(
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 32,
                                color: cs.onPrimary,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${manager.successRate}%',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                  Text(
                                    'อัตราความสำเร็จ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: cs.onPrimary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Completed Tasks Card
                      Expanded(
                        child: Container(
                          height: 140,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.tertiary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 32,
                                color: cs.onPrimary,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${manager.completedTasksCount}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                  Text(
                                    'งานที่เสร็จสิ้น',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: cs.onPrimary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Project Progress
              Text(
                'ความคืบหน้าของโครงงาน',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ProjectManager>(
                builder: (context, manager, child) {
                  final projects = manager.projects;
                  if (projects.isEmpty) {
                    return const Text('ไม่มีโปรเจกต์');
                  }
                  return Column(
                    children: projects.map((project) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  project.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  '${project.progress} %',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: project.progress / 100,
                                minHeight: 8,
                                backgroundColor: cs.outline,
                                color: _getProjectColor(
                                  projects.indexOf(project),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Weekly Stats
              Text(
                'สถิติรายสัปดาห์',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Consumer<ProjectManager>(
                builder: (context, manager, child) {
                  final stats = manager.weeklyStats;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        '${stats['created']}',
                        'งานที่สร้าง',
                        cs.onSurface,
                      ),
                      _buildStatItem(
                        '${stats['completed']}',
                        'งานที่เสร็จ',
                        Colors.green,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<ProjectManager>(
                builder: (context, manager, child) {
                  final stats = manager.weeklyStats;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        '${stats['doing']}',
                        'งานที่กำลังทำ',
                        Colors.blue,
                      ),
                      _buildStatItem(
                        '${stats['overdue']}',
                        'งานที่เลยกำหนด',
                        Colors.red,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProjectColor(int index) {
    const colors = [
      Color(0xFFCFBDF6), // Purple
      Color(0xFFFFC7C6), // Pinkish
      Color(0xFFCFBDF6), // Reusing purple for demo
    ];
    return colors[index % colors.length];
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return SizedBox(
      width: 150, // Fixed width for alignment
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
