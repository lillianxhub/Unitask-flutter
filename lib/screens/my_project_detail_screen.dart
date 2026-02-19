import 'package:flutter/material.dart';

class MyProjectDetailScreen extends StatelessWidget {
  const MyProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final projectName = args?['name'] as String? ?? 'Mobile project';

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
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF828282),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                '10 Task',
                                style: TextStyle(
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
                              const Text(
                                '4 members',
                                style: TextStyle(
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
                          _detailRow('ผู้รับผิดชอบ', 'คุณ,เพชร,บอส'),
                          const SizedBox(height: 16),
                          _detailRow('วันครบกำหนด', '12 ม.ค'),
                          const SizedBox(height: 16),
                          _detailRow('สถานะ', 'ยังไม่เริ่มทำ'),
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
                          _commentItem(),
                          const SizedBox(height: 12),
                          _commentItem(),
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
                      decoration: const InputDecoration(
                        hintText: 'เขียนความคิดเห็น...',
                        hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
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
                ],
              ),
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

  Widget _commentItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFCFBDF6),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'This is a comment...',
                style: TextStyle(color: Color(0xFF4F4F4F)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
