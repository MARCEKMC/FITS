import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () async {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      if (authViewModel.user == null) {
        Navigator.pushReplacementNamed(context, '/auth');
      } else {
        // Aquí deberías cargar el UserProfile real de Firestore.
        if (userViewModel.isProfileComplete) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/complete_profile');
        }
      }
    });

    return const Scaffold(
      body: Center(child: Text('SPLASH LOGO', style: TextStyle(fontSize: 36))),
    );
  }
}