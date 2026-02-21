import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailBottomSheet extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    required this.onDelete,
  });

  static void show(BuildContext context, Task task, VoidCallback onDelete) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          TaskDetailBottomSheet(task: task, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            task.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            task.description.isEmpty ? 'No description' : task.description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Due Date: ${_formatDate(task.dueDate)}',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Confirm delete or just delete?
                // Plan said "Click Delete -> Task vanishes immediately"
                onDelete();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Delete Task',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
