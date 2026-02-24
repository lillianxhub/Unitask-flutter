import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/project_manager.dart';
import '../models/user_manager.dart';
import '../widgets/bottom_nav.dart';

class MyProjectDetailScreen extends StatefulWidget {
  const MyProjectDetailScreen({super.key});

  @override
  State<MyProjectDetailScreen> createState() => _MyProjectDetailScreenState();
}

class _MyProjectDetailScreenState extends State<MyProjectDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<String> _memberNames = [];
  bool _isLoadingMembers = true;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchMemberNames();
  }

  Future<void> _fetchMemberNames() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? '';
    if (projectName.isEmpty) return;

    try {
      final project = context.read<ProjectManager>().projects.firstWhere(
        (p) => p.name == projectName,
        orElse: () =>
            Project(name: '', description: '', dueDate: '', ownerId: ''),
      );

      if (project.members.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingMembers = false;
          });
        }
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: project.members)
          .get();

      final names = querySnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();

      if (mounted) {
        setState(() {
          _memberNames = names.isNotEmpty ? names : project.members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? 'Mobile project';

    final projectManager = context.watch<ProjectManager>();
    final project = projectManager.projects.firstWhere(
      (p) => p.name == projectName,
      orElse: () =>
          Project(name: projectName, description: '', dueDate: '', ownerId: ''),
    );

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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project info header
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
                          Text(
                            project.description.isEmpty
                                ? 'No Description'
                                : project.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF828282),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${project.tasks.length} Task',
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
                                '${project.members.length} members',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4F4F4F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progress Bar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4F4F4F),
                                ),
                              ),
                              Text(
                                '${project.progress}%',
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
                              value: project.tasks.isEmpty
                                  ? 0
                                  : project.progress / 100,
                              backgroundColor: const Color(0xFFE0E0E0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFCFBDF6),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Detail section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                : _memberNames.join(', '),
                          ),
                          const SizedBox(height: 16),
                          _detailRow('วันครบกำหนด', project.dueDate),
                          const SizedBox(height: 16),
                          _detailRow('สถานะ', project.status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Comment section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                    ),
                  ],
                ),
              ),
            ),
            // Comment input
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
                        final comment = Comment(
                          id: UniqueKey().toString(),
                          authorEmail: userManager.email,
                          authorName: userManager.name,
                          text: text,
                          timestamp: DateTime.now(),
                        );
                        context.read<ProjectManager>().addComment(
                          project.name,
                          comment,
                        );
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
}
