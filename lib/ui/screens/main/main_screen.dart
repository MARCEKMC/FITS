import 'package:flutter/material.dart';
import '../../widgets/main/bottom_nav_bar.dart';
import '../../../modules/fitsi/widgets/fitsi_fab.dart';
import '../home/home_screen.dart';
import '../../../modules/efficiency/screens/efficiency_screen.dart';
import '../../../modules/health/screens/health_screen.dart';
import '../../../modules/profile/screens/profile_screen.dart';

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
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 270),
            child: _pages[_currentIndex],
          ),
          // FITSI FAB flotante
          const FitsiFAB(),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}