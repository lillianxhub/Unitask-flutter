import 'package:flutter/material.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final List<String> members;
  final void Function(
    String name,
    String description,
    String assignedTo,
    String dueDate,
    String priority,
  )?
  onSave;

  const AddTaskBottomSheet({super.key, required this.members, this.onSave});

  static void show(
    BuildContext context, {
    required List<String> members,
    void Function(
      String name,
      String description,
      String assignedTo,
      String dueDate,
      String priority,
    )?
    onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTaskBottomSheet(members: members, onSave: onSave),
    );
  }

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _dueDateController = TextEditingController();
  String? _assignedTo;
  String _priority = 'Medium';

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      _assignedTo = widget.members.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dueDateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Task',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: cs.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Task name
            TextField(
              controller: _nameController,
              style: TextStyle(color: cs.onSurface),
              decoration: _inputDecoration('Enter task name'),
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: _descController,
              maxLines: 4,
              style: TextStyle(color: cs.onSurface),
              decoration: _inputDecoration('Enter description'),
            ),
            const SizedBox(height: 16),
            // Assigned To
            Container(
              width: double.infinity,
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.members.contains(_assignedTo)
                      ? _assignedTo
                      : null,
                  hint: Text(
                    'Assigned To',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  dropdownColor: cs.surface,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _assignedTo = newValue;
                      });
                    }
                  },
                  items: widget.members.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Due date
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dueDateController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: _inputDecoration('Enter due date').copyWith(
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Priority
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ' Priority',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildPriorityChip('High', Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildPriorityChip('Medium', Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildPriorityChip('Low', Colors.blue)),
              ],
            ),
            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.secondary, cs.tertiary]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(context);
                      widget.onSave?.call(
                        name,
                        _descController.text.trim(),
                        _assignedTo ?? '',
                        _dueDateController.text.trim(),
                        _priority,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPriorityChip(String label, MaterialColor color) {
    final isSelected = _priority == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _priority = label;
        });
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color : color.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.shade200,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
