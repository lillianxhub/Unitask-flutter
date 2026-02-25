import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ChangePasswordBottomSheet(),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

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

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog('ข้อมูลไม่ครบถ้วน', 'กรุณากรอกรหัสผ่านให้ครบทุกช่อง');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('รหัสผ่านไม่ตรงกัน', 'กรุณายืนยันรหัสผ่านใหม่ให้ตรงกัน');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorDialog(
        'รหัสผ่านสั้นเกินไป',
        'รหัสผ่านใหม่ต้องมีความยาวอย่างน้อย 6 ตัวอักษร',
      );
      return;
    }

    setState(() => _isLoading = true);
    final error = await context.read<UserManager>().updatePassword(
      currentPassword,
      newPassword,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pop(context); // Close bottom sheet on success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จแล้ว')),
      );
    } else {
      _showErrorDialog('เปลี่ยนรหัสผ่านไม่สำเร็จ', error);
      if (error.contains('บัญชีนี้เข้าสู่ระบบด้วย Google')) {
        // Automatically close the bottom sheet after 2 seconds if it's a Google account
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    bool isPassword,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เปลี่ยนรหัสผ่านใหม่',
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
          _buildTextField('รหัสผ่านเดิม', _currentPasswordController, true),
          const SizedBox(height: 16),
          _buildTextField(
            'รหัสผ่านใหม่ (อย่างน้อย 6 ตัว)',
            _newPasswordController,
            true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'ยืนยันรหัสผ่านใหม่',
            _confirmPasswordController,
            true,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cs.secondary, cs.tertiary]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'บันทึก',
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
