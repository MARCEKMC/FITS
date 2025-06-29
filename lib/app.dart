import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/health_viewmodel.dart';
import 'viewmodel/food_viewmodel.dart';
import 'viewmodel/water_viewmodel.dart';
import 'viewmodel/selected_date_viewmodel.dart';
import 'viewmodel/exercise_viewmodel.dart'; // AGREGA ESTE IMPORT

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
        ChangeNotifierProvider(create: (_) => ExerciseViewModel()), // AGREGA ESTA LÍNEA
      ],
      child: MaterialApp(
        title: 'Fits App',
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/splash',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}