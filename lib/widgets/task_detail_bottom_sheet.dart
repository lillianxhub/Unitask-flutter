import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailBottomSheet extends StatefulWidget {
  final Task task;
  final bool canEdit;
  final VoidCallback? onDelete;
  final ValueChanged<Task>? onUpdate;
  final ValueChanged<String>? onComment;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    this.canEdit = false,
    this.onDelete,
    this.onUpdate,
    this.onComment,
  });

  static void show(
    BuildContext context,
    Task task, {
    bool canEdit = false,
    VoidCallback? onDelete,
    ValueChanged<Task>? onUpdate,
    ValueChanged<String>? onComment,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: TaskDetailBottomSheet(
            task: task,
            canEdit: canEdit,
            onDelete: onDelete,
            onUpdate: onUpdate,
            onComment: onComment,
          ),
        ),
      ),
    );
  }

  @override
  State<TaskDetailBottomSheet> createState() => _TaskDetailBottomSheetState();
}

class _TaskDetailBottomSheetState extends State<TaskDetailBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
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
                color: cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.canEdit)
                Checkbox(
                  value: _isCompleted,
                  activeColor: const Color(0xFFCFBDF6),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _isCompleted = val;
                      });
                      if (widget.onUpdate != null) {
                        final updatedTask = Task(
                          title: widget.task.title,
                          description: widget.task.description,
                          dueDate: widget.task.dueDate,
                          createdDate: widget.task.createdDate,
                          assignedTo: widget.task.assignedTo,
                          priority: widget.task.priority,
                          isCompleted: _isCompleted,
                          comments: List.from(widget.task.comments),
                        );
                        widget.onUpdate!(updatedTask);
                      }
                    }
                  },
                )
              else if (_isCompleted)
                const Icon(Icons.check_circle, color: Color(0xFFCFBDF6)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.task.description.isEmpty
                ? 'No description'
                : widget.task.description,
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Due Date: ${_formatDate(widget.task.dueDate)}',
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (widget.task.comments.isEmpty)
            Text(
              'No comments yet.',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
            )
          else
            ...widget.task.comments.map(
              (comment) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFCFBDF6),
                      child: Text(
                        comment.authorName.isNotEmpty
                            ? comment.authorName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            comment.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (widget.canEdit) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty && widget.onComment != null) {
                      widget.onComment!(text);
                      _commentController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  icon: Icon(Icons.send, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
          if (widget.onDelete != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDelete!();
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
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
