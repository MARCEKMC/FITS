import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';

class VerificationLoadingScreen extends StatefulWidget {
  const VerificationLoadingScreen({super.key});

  @override
  State<VerificationLoadingScreen> createState() =>
      _VerificationLoadingScreenState();
}

class _VerificationLoadingScreenState extends State<VerificationLoadingScreen> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _waitForVerification();
  }

  void _waitForVerification() async {
    setState(() => _checking = true);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final verified = await authViewModel.isEmailVerified();
      if (verified) {
        Navigator.pushReplacementNamed(context, '/complete_profile');
        break;
      }
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
                'Por favor verifica tu correo electrónico\ny luego vuelve a la app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}