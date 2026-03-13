import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailBottomSheet extends StatefulWidget {
  final Task task;
  final bool canEdit;
  final bool canMarkComplete;
  final bool canComment;
  final List<String> members;
  final VoidCallback? onDelete;
  final ValueChanged<Task>? onUpdate;
  final ValueChanged<String>? onComment;

  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    this.canEdit = false,
    this.canMarkComplete = false,
    this.canComment = false,
    this.members = const [],
    this.onDelete,
    this.onUpdate,
    this.onComment,
  });

  static void show(
    BuildContext context,
    Task task, {
    bool canEdit = false,
    bool canMarkComplete = false,
    bool canComment = false,
    List<String> members = const [],
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
            canMarkComplete: canMarkComplete,
            canComment: canComment,
            members: members,
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
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  late DateTime _dueDate;
  late String _priority;
  late String? _assignedTo;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _assignedTo = widget.task.assignedTo;
  }

  void _updateTask() {
    if (widget.onUpdate != null) {
      final updatedTask = Task(
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : widget.task.title,
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        createdDate: widget.task.createdDate,
        assignedTo: _assignedTo,
        priority: _priority,
        isCompleted: _isCompleted,
        comments: List.from(widget.task.comments),
      );
      widget.onUpdate!(updatedTask);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
      _updateTask();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
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
                child: widget.canEdit
                    ? Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) _updateTask();
                        },
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Task title',
                            hintStyle: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.4),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      )
                    : Text(
                        widget.task.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (widget.canMarkComplete || widget.canEdit)
                Checkbox(
                  value: _isCompleted,
                  activeColor: const Color(0xFFCFBDF6),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _isCompleted = val;
                      });
                      if (widget.onUpdate != null) {
                        _updateTask();
                      }
                    }
                  },
                )
              else if (_isCompleted)
                const Icon(Icons.check_circle, color: Color(0xFFCFBDF6)),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.canEdit)
            Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  _updateTask();
                }
              },
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                style: TextStyle(fontSize: 16, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Add description',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            )
          else
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Due Date
              Expanded(
                child: InkWell(
                  onTap: widget.canEdit ? _pickDate : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${_formatDate(_dueDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Priority
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 20,
                      color: _getPriorityColor(_priority),
                    ),
                    const SizedBox(width: 8),
                    if (widget.canEdit)
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _priority,
                          isDense: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: cs.onSurface,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withValues(alpha: 0.8),
                          ),
                          items: ['High', 'Medium', 'Low']
                              .map(
                                (p) =>
                                    DropdownMenuItem(value: p, child: Text(p)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _priority = val;
                              });
                              _updateTask();
                            }
                          },
                        ),
                      )
                    else
                      Text(
                        _priority,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Assigned To section
          if (widget.canEdit && widget.members.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Assigned to: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.members.contains(_assignedTo)
                          ? _assignedTo
                          : null,
                      hint: Text(
                        'Not assigned',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                      isDense: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: cs.onSurface,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.8),
                      ),
                      items: widget.members
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _assignedTo = val;
                        });
                        _updateTask();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_assignedTo != null && _assignedTo!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Assigned to: $_assignedTo',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
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
          if (widget.canComment || widget.canEdit) ...[
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.purple;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
