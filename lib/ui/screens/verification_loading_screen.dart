import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';

class VerificationLoadingScreen extends StatefulWidget {
  const VerificationLoadingScreen({super.key});

  @override
  State<VerificationLoadingScreen> createState() => _VerificationLoadingScreenState();
}

class _VerificationLoadingScreenState extends State<VerificationLoadingScreen> {
  bool _checking = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _waitForVerification();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _waitForVerification() async {
    setState(() => _checking = true);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    while (!_disposed) {
      await Future.delayed(const Duration(seconds: 2));
      final verified = await authViewModel.isEmailVerified();
      if (verified) {
        if (!_disposed) {
          Navigator.pushReplacementNamed(context, '/complete_profile');
        }
        break;
      }
    }
    if (!_disposed) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Por favor verifica tu correo electrónico\ny luego vuelve a la app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                final verified = await authViewModel.isEmailVerified();
                if (verified) {
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/complete_profile');
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aún no se ha verificado el correo.')),
                    );
                  }
                }
              },
              child: const Text('Ya verifiqué mi correo'),
            ),
          ],
        ),
      ),
    );
  }
}