import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late DateTime _dueDate;
  late String _priority;
  late List<String> _assignedTo;
  late List<String> _completedBy;

  /// Starts in read-only mode; user taps pencil icon to enable editing.
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _assignedTo = List<String>.from(widget.task.assignedTo);
    _completedBy = List<String>.from(widget.task.completedBy);
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
        assignedTo: List<String>.from(_assignedTo),
        completedBy: List<String>.from(_completedBy),
        priority: _priority,
        comments: List.from(widget.task.comments),
      );
      widget.onUpdate!(updatedTask);
    }
  }

  String get _currentUserEmail {
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }

  double get _progress {
    if (_assignedTo.isEmpty) return 0.0;
    final done = _assignedTo.where((e) => _completedBy.contains(e)).length;
    return done / _assignedTo.length;
  }

  bool get _isFullyCompleted {
    if (_assignedTo.isEmpty) return false;
    return _assignedTo.every((e) => _completedBy.contains(e));
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
          // --- Drag handle + action icons row ---
          Row(
            children: [
              const Spacer(),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4),
          // --- Action icons (pencil + delete) at top-right ---
          if (widget.canEdit || widget.onDelete != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.canEdit)
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.edit_off : Icons.edit,
                      color: _isEditing ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                      size: 22,
                    ),
                    tooltip: _isEditing ? 'Done editing' : 'Edit task',
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: cs.error,
                      size: 22,
                    ),
                    tooltip: 'Delete task',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Task'),
                          content: const Text('Are you sure you want to delete this task?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                widget.onDelete!();
                                Navigator.pop(context);
                              },
                              child: Text('Delete', style: TextStyle(color: cs.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          const SizedBox(height: 8),
          // --- Title ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _isEditing
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
                        _titleController.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (_isFullyCompleted)
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28)
              else if (_assignedTo.isNotEmpty)
                Text(
                  '${_assignedTo.where((e) => _completedBy.contains(e)).length}/${_assignedTo.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
            ],
          ),
          // Progress bar
          if (_assignedTo.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isFullyCompleted ? const Color(0xFF4CAF50) : cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isFullyCompleted
                  ? 'All members completed ✅'
                  : '${_assignedTo.where((e) => _completedBy.contains(e)).length} of ${_assignedTo.length} completed',
              style: TextStyle(
                fontSize: 12,
                color: _isFullyCompleted
                    ? const Color(0xFF4CAF50)
                    : cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // --- Description ---
          if (_isEditing)
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
              _descriptionController.text.isEmpty
                  ? 'No description'
                  : _descriptionController.text,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          const SizedBox(height: 24),
          // --- Due Date & Priority row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Due Date
              Expanded(
                child: InkWell(
                  onTap: _isEditing ? _pickDate : null,
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
                    if (_isEditing)
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
          // --- Assigned To section with per-person completion checkboxes ---
          if (_isEditing && widget.members.isNotEmpty) ...[
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
                  'Assigned to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            // Per-person completion checkboxes
            if (_assignedTo.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._assignedTo.map((email) {
                final isDone = _completedBy.contains(email);
                final isMe = email == _currentUserEmail;
                final canToggle = _isEditing || isMe;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isDone,
                          activeColor: const Color(0xFF4CAF50),
                          onChanged: canToggle
                              ? (val) {
                                  setState(() {
                                    if (val == true) {
                                      if (!_completedBy.contains(email)) {
                                        _completedBy.add(email);
                                      }
                                    } else {
                                      _completedBy.remove(email);
                                    }
                                  });
                                  _updateTask();
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isMe ? '$email (you)' : email,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (isDone)
                        const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16)
                      else
                        Icon(Icons.radio_button_unchecked, color: cs.onSurface.withValues(alpha: 0.3), size: 16),
                      if (_isEditing)
                        IconButton(
                          icon: Icon(Icons.close, size: 16, color: cs.error),
                          onPressed: () {
                            setState(() {
                              _assignedTo.remove(email);
                              _completedBy.remove(email);
                            });
                            _updateTask();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                );
              }),
            ],
            // Dropdown to add more members
            if (widget.members.where((m) => !_assignedTo.contains(m)).isNotEmpty) ...[
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: null,
                  hint: Text(
                    _assignedTo.isEmpty ? 'Select member' : 'Add another member',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                  ),
                  isDense: true,
                  icon: Icon(Icons.arrow_drop_down, color: cs.onSurface),
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.8),
                  ),
                  items: widget.members
                      .where((m) => !_assignedTo.contains(m))
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _assignedTo.add(val);
                      });
                      _updateTask();
                    }
                  },
                ),
              ),
            ],
          ] else if (_assignedTo.isNotEmpty) ...[
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
                  'Assigned to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Per-person completion checkboxes (read-only or self-toggle for assignees)
            ..._assignedTo.map((email) {
              final isDone = _completedBy.contains(email);
              final isMe = email == _currentUserEmail;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isDone,
                        activeColor: const Color(0xFF4CAF50),
                        onChanged: isMe && widget.onUpdate != null
                            ? (val) {
                                setState(() {
                                  if (val == true) {
                                    if (!_completedBy.contains(email)) {
                                      _completedBy.add(email);
                                    }
                                  } else {
                                    _completedBy.remove(email);
                                  }
                                });
                                _updateTask();
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isMe ? '$email (you)' : email,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (isDone)
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16)
                    else
                      Icon(Icons.radio_button_unchecked, color: cs.onSurface.withValues(alpha: 0.3), size: 16),
                  ],
                ),
              );
            }),
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
