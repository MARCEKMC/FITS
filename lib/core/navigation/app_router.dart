import 'package:flutter/material.dart';
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/auth/auth_screen.dart';
import '../../ui/screens/verification_loading_screen.dart';
import '../../ui/screens/complete_profile_screen.dart';
import '../../ui/screens/home/home_screen.dart';

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
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}