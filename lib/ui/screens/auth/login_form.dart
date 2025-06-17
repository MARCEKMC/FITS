import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/auth_viewmodel.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passController,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          _loading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);
                      try {
                        final user = await authViewModel.signInWithEmail(
                            _emailController.text, _passController.text);
                        if (user != null) {
                          if (user.emailVerified) {
                            // CAMBIO: SIEMPRE NAVEGA A SPLASH
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/splash',
                              (route) => false,
                            );
                          } else {
                            Navigator.pushReplacementNamed(
                                context, '/verification_loading');
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')));
                      }
                      setState(() => _loading = false);
                    },
                    child: const Text('Entrar'),
                  ),
                ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Google'),
                onPressed: () async {
                  setState(() => _loading = true);
                  try {
                    final user = await authViewModel.signInWithGoogle();
                    if (user != null) {
                      // CAMBIO: SIEMPRE NAVEGA A SPLASH
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/splash',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')));
                  }
                  setState(() => _loading = false);
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.facebook),
                label: const Text('Facebook'),
                onPressed: () async {
                  setState(() => _loading = true);
                  try {
                    final user = await authViewModel.signInWithFacebook();
                    if (user != null) {
                      // CAMBIO: SIEMPRE NAVEGA A SPLASH
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/splash',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')));
                  }
                  setState(() => _loading = false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}