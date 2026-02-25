import 'package:flutter/material.dart';

class AddProjectBottomSheet extends StatefulWidget {
  final void Function(String name, String description, String dueDate)? onSave;

  const AddProjectBottomSheet({super.key, this.onSave});

  static void show(
    BuildContext context, {
    void Function(String name, String description, String dueDate)? onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddProjectBottomSheet(onSave: onSave),
    );
  }

  @override
  State<AddProjectBottomSheet> createState() => _AddProjectBottomSheetState();
}

class _AddProjectBottomSheetState extends State<AddProjectBottomSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF8A80),
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ตกลง',
              style: TextStyle(
                color: Color(0xFF6750A4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add New Project',
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
          // Project name
          TextField(
            controller: _nameController,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter project name',
              hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          TextField(
            controller: _descController,
            maxLines: 4,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter description',
              hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
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
                decoration: InputDecoration(
                  hintText: 'Enter due date',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
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
                  final desc = _descController.text.trim();
                  final dueDate = _dueDateController.text.trim();

                  if (name.isEmpty || desc.isEmpty || dueDate.isEmpty) {
                    _showErrorDialog(
                      'ข้อมูลไม่ครบถ้วน',
                      'กรุณากรอกชื่อโปรเจกต์ รายละเอียด และกำหนดส่งให้ครบทุกช่อง',
                    );
                    return;
                  }

                  Navigator.pop(context);
                  widget.onSave?.call(name, desc, dueDate);
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
    );
  }
}
