import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/health_viewmodel.dart'; // <--- Corrige esto si no está

class FitsApp extends StatelessWidget {
  const FitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => HealthViewModel()), // <--- Cambia aquí también
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