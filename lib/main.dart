import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await initializeDateFormatting('es', null);
    runApp(const FitsApp());
  } catch (e) {
    // En apps reales: muestra un error amigable o reporta el fallo
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Error al iniciar: $e')),
      ),
    ));
  }
}