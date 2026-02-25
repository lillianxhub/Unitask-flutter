import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_projects_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('tabIndex')) {
        _selectedIndex = args['tabIndex'] as int;
      }
      _isInit = true;
    }
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const MyProjectsScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
