import 'package:flutter/material.dart';
import '../models/locale_manager.dart';
import '../widgets/login_bottom_sheet.dart';
import '../widgets/register_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../models/user_manager.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(36),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCFBDF6), Color(0xFFFFC7C6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Title
              const Text(
                'UniTask = )',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Organize your study tasks.\n Stay focused. Get things done.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
              ),
              // Logo placeholder
              const Expanded(
                child: Center(
                  child: Image(
                    image: AssetImage('assets/images/unitask_logo.png'),
                  ),
                ),
              ),
              // Create Account button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => RegisterBottomSheet.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Log In button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => LoginBottomSheet.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Google Sign In button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Capture navigator and messenger early before async gap
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    final error = await context
                        .read<UserManager>()
                        .signInWithGoogle();

                    if (error == null) {
                      navigator.pushReplacementNamed(
                        '/splash',
                        arguments: 'HOME',
                      );
                    } else {
                      messenger.showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 40,
                    color: Color(0xFFDB4437),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Guest Login Button
              TextButton(
                onPressed: () {
                  context.read<UserManager>().loginAsGuest();
                  Navigator.pushReplacementNamed(
                    context,
                    '/splash',
                    arguments: 'HOME',
                  );
                },
                child: Text(
                  LocaleManager.instance.t('guest_login'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
