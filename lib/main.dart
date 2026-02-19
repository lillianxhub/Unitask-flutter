import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_projects_screen.dart';
import 'screens/my_project_detail_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/members_screen.dart';

void main() {
  runApp(const UniTaskApp());
}

class UniTaskApp extends StatelessWidget {
  const UniTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCFBDF6)),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/splash': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeScreen(),
        '/my-projects': (_) => const MyProjectsScreen(),
        '/my-project-detail': (_) => const MyProjectDetailScreen(),
        '/project-detail': (_) => const ProjectDetailScreen(),
        '/members': (_) => const MembersScreen(),
      },
    );
  }
}
