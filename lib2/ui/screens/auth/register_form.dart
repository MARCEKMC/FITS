import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/auth_viewmodel.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
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
                        final user = await authViewModel.registerWithEmail(
                            _emailController.text, _passController.text);
                        if (user != null) {
                          // Si tu flujo requiere verificación de email, primero ve a verificación:
                          Navigator.pushReplacementNamed(
                              context, '/verification_loading');
                          // Si NO requieres verificación de email, usa esto en vez de lo de arriba:
                          // Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')));
                      }
                      setState(() => _loading = false);
                    },
                    child: const Text('Registrarse'),
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