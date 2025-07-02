import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class VerificationLoadingScreen extends StatefulWidget {
  const VerificationLoadingScreen({super.key});

  @override
  State<VerificationLoadingScreen> createState() =>
      _VerificationLoadingScreenState();
}

class _VerificationLoadingScreenState extends State<VerificationLoadingScreen>
    with SingleTickerProviderStateMixin {
  bool _disposed = false;
  bool _resending = false;
  late AnimationController _dotsController;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _dotsAnimation = StepTween(begin: 1, end: 4).animate(_dotsController);
    _waitForVerification();
  }

  @override
  void dispose() {
    _disposed = true;
    _dotsController.dispose();
    super.dispose();
  }

  Future<void> _waitForVerification() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    while (!_disposed) {
      await Future.delayed(const Duration(seconds: 2));
      final verified = await authViewModel.isEmailVerified();
      if (verified && mounted && !_disposed) {
        Navigator.pushReplacementNamed(context, '/splash');
        break;
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _resending = true);
    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final user = authViewModel.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Correo de verificación reenviado.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _manualCheckVerification() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final verified = await authViewModel.isEmailVerified();
    if (verified && mounted) {
      Navigator.pushReplacementNamed(context, '/splash');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún no se ha verificado el correo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double imageHeight = 180;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/core/utils/images/char_verificar.png',
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 22),
                  AnimatedBuilder(
                    animation: _dotsController,
                    builder: (_, __) {
                      int count = _dotsAnimation.value;
                      return Text(
                        List.generate(count, (i) => '.').join(' '),
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.black87,
                          letterSpacing: 6,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      "PORFAVOR VERIFICA TU CORREO\nELECTRONICO Y LUEGO VUELVE\nA LA APLICACION",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 260,
                    height: 36,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      onPressed: _resending ? null : _resendVerificationEmail,
                      child: _resending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Reenviar correo de verificación',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 13.5,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 260,
                    height: 36,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      onPressed: _manualCheckVerification,
                      child: const Text(
                        'Ya verifiqué mi correo',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 13.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/auth');
                    },
                    child: const Text(
                      "volver",
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
