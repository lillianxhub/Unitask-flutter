import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startLoading();
  }

  bool _started = false;

  void _startLoading() {
    if (_started) return;
    _started = true;
    final nextScreen = ModalRoute.of(context)?.settings.arguments as String?;
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (nextScreen == 'HOME') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCFBDF6), Color(0xFFFFC7C6)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Text(
              'UniTask = )',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: [
                  Shadow(
                    offset: Offset(2, 4),
                    blurRadius: 8,
                    color: Color(0x40000000),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'A Task Management Application',
              style: TextStyle(fontSize: 18, color: Color(0xFF1A1A1A)),
            ),
            const Spacer(flex: 2),
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: Color(0xFF6750A4),
                strokeWidth: 4,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
