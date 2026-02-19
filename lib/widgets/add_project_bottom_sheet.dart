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
      backgroundColor: Colors.white,
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
              const Text(
                'Add New Project',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Project name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter project name',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
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
            decoration: InputDecoration(
              hintText: 'Enter description',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
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
                decoration: InputDecoration(
                  hintText: 'Enter due date',
                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF999999),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFCFBDF6), Color(0xFFFFC7C6)],
                ),
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
                      _dueDateController.text.trim(),
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
    );
  }
}
