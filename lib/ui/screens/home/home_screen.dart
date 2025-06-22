import 'package:flutter/material.dart';
import 'focus_screen.dart';
import 'schedule_screen.dart';
import 'notes_screen.dart';
import 'agenda_screen.dart';
import 'efficiency_screen.dart';
import 'health_screen.dart';
import 'profile_screen.dart';
import '../../widgets/minimal_button.dart';
import '../../widgets/chat_input_bar.dart';

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

  void _goTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static Widget _homeTab(BuildContext context, void Function(Widget) goTo) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 32, bottom: 18),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Asunto importante
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Asunto importante",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "¡No olvides repasar tus apuntes para el examen de mañana!",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            // Botones minimalistas
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                MinimalButton(
                  icon: Icons.center_focus_strong,
                  label: "Focus",
                  onTap: () => goTo(const FocusScreen()),
                ),
                MinimalButton(
                  icon: Icons.schedule,
                  label: "Ver Horario",
                  onTap: () => goTo(const ScheduleScreen()),
                ),
                MinimalButton(
                  icon: Icons.notes,
                  label: "Ver Apuntes",
                  onTap: () => goTo(const NotesScreen()),
                ),
                MinimalButton(
                  icon: Icons.event_note,
                  label: "Ver Agenda",
                  onTap: () => goTo(const AgendaScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _homeTab(context, _goTo),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Eficiencia'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Salud'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}