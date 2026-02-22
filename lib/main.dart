import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'models/project_manager.dart';
import 'models/user_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/my_projects_screen.dart';
import 'screens/my_project_detail_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/members_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/main_layout.dart';

import 'screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectManager.instance),
        ChangeNotifierProvider(create: (_) => UserManager.instance),
      ],
      child: const UniTaskApp(),
    ),
  );
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
        '/home': (_) => const MainLayout(),
        '/my-projects': (_) => const MyProjectsScreen(),
        '/my-project-detail': (_) => const MyProjectDetailScreen(),
        '/project-detail': (_) => const ProjectDetailScreen(),
        '/members': (_) => const MembersScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/notifications': (_) => const NotificationsScreen(),
      },
    );
  }
}
