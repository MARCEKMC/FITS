import 'package:flutter/material.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();

  void _goToPage(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => _goToPage(0),
                  child: const Text('Login')),
              TextButton(
                  onPressed: () => _goToPage(1),
                  child: const Text('Registro')),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: const [
                LoginForm(),
                RegisterForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}