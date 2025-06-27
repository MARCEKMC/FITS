import 'package:flutter/material.dart';
import '../../widgets/home/bottom_navbar.dart';
import '../../widgets/home/minimal_button.dart';
import '../../widgets/home/chat_input_bar.dart';

// Importa aquí tus pantallas reales
import '../main/main_screen.dart';
import '../efficiency/efficiency_screen.dart';
import '../health/health_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cambia estos por tus pantallas reales
    final tabs = [
      const MainScreen(),
      const EfficiencyScreen(),
      const HealthScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: tabs[_selectedIndex],
          ),
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10), // 10px de separación
              child: ChatInputBar(
                onSend: (msg) {
                  print("Mensaje a FITS: $msg");
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}