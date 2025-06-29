import 'package:flutter/material.dart';
import 'package:fits/ui/screens/auth/splash_screen.dart';
import 'package:fits/ui/screens/auth/auth_screen.dart';
import 'package:fits/ui/screens/auth/verification_loading_screen.dart';
import 'package:fits/ui/screens/auth/complete_profile_screen.dart';
import 'package:fits/ui/screens/main/main_screen.dart';

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
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}