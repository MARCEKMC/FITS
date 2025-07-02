import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'modules/auth/viewmodels/auth_viewmodel.dart';
import 'modules/profile/viewmodels/user_viewmodel.dart';
import 'modules/health/viewmodels/health_viewmodel.dart';
import 'modules/health/viewmodels/food_viewmodel.dart';
import 'modules/health/viewmodels/water_viewmodel.dart';
import 'shared/viewmodels/selected_date_viewmodel.dart';
import 'modules/health/viewmodels/exercise_viewmodel.dart';
import 'modules/efficiency/viewmodels/notes_viewmodel.dart';
import 'modules/efficiency/viewmodels/secure_notes_viewmodel.dart';
import 'modules/efficiency/viewmodels/tasks_viewmodel.dart';
import 'modules/fitsi/viewmodels/fitsi_chat_viewmodel.dart';

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
        ChangeNotifierProvider(create: (_) => FitsiChatViewModel()),
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