import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // Inicializar formato de fechas en español
  await initializeDateFormatting('es', null);
  
  runApp(const FitsApp());
}