import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/health_viewmodel.dart';
import 'viewmodel/food_viewmodel.dart';
import 'viewmodel/water_viewmodel.dart';
import 'viewmodel/selected_date_viewmodel.dart';
import 'viewmodel/exercise_viewmodel.dart';
import 'viewmodel/notes_viewmodel.dart';
import 'viewmodel/secure_notes_viewmodel.dart';
import 'viewmodel/tasks_viewmodel.dart';

class FitsApp extends StatelessWidget {
  const FitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => HealthViewModel()),
        ChangeNotifierProvider(create: (_) => FoodViewModel()),
        ChangeNotifierProvider(create: (_) => WaterViewModel()),
        ChangeNotifierProvider(create: (_) => SelectedDateViewModel()),
        ChangeNotifierProvider(create: (_) => ExerciseViewModel()),
        ChangeNotifierProvider(create: (_) => NotesViewModel()),
        ChangeNotifierProvider(create: (_) => SecureNotesViewModel()),
        ChangeNotifierProvider(create: (_) => TasksViewModel()),
      ],
      child: MaterialApp(
        title: 'Fits App',
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/splash',
        debugShowCheckedModeBanner: false,
        // Agregamos soporte para localizaciones
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés
        ],
        locale: const Locale('es', 'ES'),
      ),
    );
  }
}