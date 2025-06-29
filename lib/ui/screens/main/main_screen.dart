import 'package:flutter/material.dart';
import '../../widgets/main/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../efficiency/efficiency_screen.dart';
import '../health/health_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _pages = [
    const HomeScreen(),
    const EfficiencyScreen(),
    const HealthScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 270),
        child: _pages[_currentIndex],
      ),
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}