import 'package:flutter/material.dart';

class RegisterBottomSheet extends StatelessWidget {
  const RegisterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const RegisterBottomSheet(),
    );
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
          const Text(
            'Welcome to Unitask',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Let's work",
            style: TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 24),
          // Name
          _buildField('Enter Name'),
          const SizedBox(height: 16),
          // Email
          _buildField('Enter Email', inputType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          // Password
          _buildField('Enter Password', obscure: true),
          const SizedBox(height: 16),
          // Confirm Password
          _buildField('Confirm Password', obscure: true),
          const SizedBox(height: 32),
          // Register button
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
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/splash',
                    (route) => false,
                    arguments: 'HOME',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Register',
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

  Widget _buildField(
    String hint, {
    bool obscure = false,
    TextInputType? inputType,
  }) {
    return TextField(
      obscureText: obscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
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
        suffixIcon: obscure
            ? const Icon(Icons.visibility_off, color: Color(0xFF888888))
            : null,
      ),
    );
  }
}
