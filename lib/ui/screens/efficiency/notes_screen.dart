import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apuntes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          "Aquí irán tus apuntes 📝",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}