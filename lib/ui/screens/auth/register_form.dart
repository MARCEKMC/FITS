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
  String? _errorMsg;

  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

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
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              errorText: _errorMsg,
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
                      final email = _emailController.text.trim();
                      final pass = _passController.text.trim();
                      setState(() {
                        _loading = true;
                        _errorMsg = null;
                      });

                      if (!_isValidEmail(email)) {
                        setState(() {
                          _errorMsg = "Correo inválido";
                          _loading = false;
                        });
                        return;
                      }
                      if (pass.length < 6) {
                        setState(() {
                          _errorMsg = "Contraseña muy corta (mínimo 6)";
                          _loading = false;
                        });
                        return;
                      }

                      try {
                        final user = await authViewModel.registerWithEmail(email, pass);
                        if (user != null) {
                          Navigator.pushReplacementNamed(context, '/verification_loading');
                        }
                      } catch (e) {
                        setState(() => _errorMsg = "Error: ${e.toString()}");
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