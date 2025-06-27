import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/auth_viewmodel.dart';
import '../../../viewmodel/user_viewmodel.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1800), () {
      _controller.reverse().then((_) => _checkAuthAndProfile());
    });
  }

  Future<void> _checkAuthAndProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    if (authViewModel.user == null) {
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      // Carga el perfil desde Firestore
      await userViewModel.loadProfile(authViewModel.user!.uid);
      if (userViewModel.isProfileComplete) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/complete_profile');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'FITS',
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              letterSpacing: 10,
              height: 1.4,
              color: const Color(0xFF23272A),
            ),
          ),
        ),
      ),
    );
  }
}