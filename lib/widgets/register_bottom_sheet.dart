import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';
import '../models/locale_manager.dart';

class RegisterBottomSheet extends StatefulWidget {
  const RegisterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const RegisterBottomSheet(),
    );
  }

  @override
  State<RegisterBottomSheet> createState() => _RegisterBottomSheetState();
}

class _RegisterBottomSheetState extends State<RegisterBottomSheet> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
            child: Text(
              LocaleManager.instance.t('ok'),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Welcome to Unitask',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's work",
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            _buildField('Enter Name', controller: _nameController),
            const SizedBox(height: 16),

            // Email
            _buildField(
              'Enter Email',
              inputType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 16),

            // Password
            _buildField(
              'Enter Password',
              controller: _passwordController,
              obscure: _obscurePassword,
              isPasswordField: true,
              inputType: TextInputType.visiblePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildField(
              'Confirm Password',
              controller: _confirmPasswordController,
              obscure: _obscureConfirmPassword,
              isPasswordField: true,
              inputType: TextInputType.visiblePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 32),

            // Register button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.secondary, cs.tertiary]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          final confirmPassword =
                              _confirmPasswordController.text;

                          if (name.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty) {
                            _showErrorDialog(
                              LocaleManager.instance.t('incomplete_data'),
                              LocaleManager.instance.t('fill_all_fields'),
                            );
                            return;
                          }
                          if (password != confirmPassword) {
                            _showErrorDialog(
                              LocaleManager.instance.t('password_mismatch'),
                              LocaleManager.instance.t(
                                'confirm_password_register',
                              ),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);
                          final error = await context
                              .read<UserManager>()
                              .register(name, email, password);
                          if (!mounted) return;
                          setState(() => _isLoading = false);

                          if (error == null) {
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/splash',
                              (route) => false,
                              arguments: 'HOME',
                            );
                          } else {
                            _showErrorDialog(
                              LocaleManager.instance.t('register_failed'),
                              error,
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
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
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
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
}
