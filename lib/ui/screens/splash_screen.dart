import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndProfile();
  }

  Future<void> _checkAuthAndProfile() async {
    await Future.delayed(const Duration(seconds: 2));
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    if (authViewModel.user == null) {
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      await userViewModel.loadProfile(authViewModel.user!.uid);
      if (userViewModel.isProfileComplete) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/complete_profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('SPLASH LOGO', style: TextStyle(fontSize: 36))),
    );
  }
}