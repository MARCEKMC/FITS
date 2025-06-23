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

  @override
  Widget build(BuildContext context) {
    // El contenido NO se mueve al abrir el teclado
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SizedBox(
          width: 420, // Máximo ancho para el PageView
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: const [
              LoginForm(),
              RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}