import 'package:flutter/material.dart';
import 'package:fits/modules/auth/screens/splash_screen.dart';
import 'package:fits/modules/auth/screens/auth_screen.dart';
import 'package:fits/modules/auth/screens/verification_loading_screen.dart';
import 'package:fits/modules/auth/screens/complete_profile_screen.dart';
import 'package:fits/ui/screens/main/main_screen.dart';
import 'package:fits/modules/efficiency/screens/schedule_screen.dart';
import 'package:fits/modules/efficiency/screens/notes_screen.dart';
import 'package:fits/modules/efficiency/screens/reports_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/verification_loading':
        return MaterialPageRoute(builder: (_) => const VerificationLoadingScreen());
      case '/complete_profile':
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
      case '/main': 
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/schedule':
        return MaterialPageRoute(builder: (_) => const ScheduleScreen());
      case '/notes':
        return MaterialPageRoute(builder: (_) => const NotesScreen());
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}