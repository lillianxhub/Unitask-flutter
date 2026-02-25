import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const LoginBottomSheet(),
    );
  }

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Let's work",
            style: TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 24),

          // Email field
          _buildField(
            'Enter Email',
            controller: _emailController,
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Password field
          _buildField(
            'Enter Password',
            controller: _passwordController,
            obscure: _obscurePassword,
            isPasswordField: true,
            onToggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          const SizedBox(height: 32),
          // Login button
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
                onPressed: _isLoading
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;
                        if (email.isNotEmpty && password.isNotEmpty) {
                          setState(() => _isLoading = true);
                          final error = await context.read<UserManager>().login(
                            email,
                            password,
                          );
                          if (!mounted) return;
                          setState(() => _isLoading = false);

                          if (error == null) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/splash',
                              (route) => false,
                              arguments: 'HOME',
                            );
                          } else {
                            _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', error);
                          }
                        } else {
                          _showErrorDialog(
                            'ข้อมูลไม่ครบถ้วน',
                            'กรุณากรอกอีเมลและรหัสผ่านให้ครบถ้วน',
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
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Log In',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Guest Login Button
          TextButton(
            onPressed: () {
              context.read<UserManager>().loginAsGuest();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/splash',
                (route) => false,
                arguments: 'HOME',
              );
            },
            child: const Text(
              'Login with Guest',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCFBDF6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String hint, {
    bool obscure = false,
    bool isPasswordField = false,
    VoidCallback? onToggleVisibility,
    TextInputType? inputType,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAEAEAE)),
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
        // Suffix icon for password
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF888888),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
} // End of State class
