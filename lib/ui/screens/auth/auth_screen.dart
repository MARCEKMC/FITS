import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  DateTime? _lastBack;

  @override
  Widget build(BuildContext context) {
    // El contenido NO se mueve al abrir el teclado
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (_lastBack == null || now.difference(_lastBack!) > const Duration(seconds: 2)) {
          _lastBack = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vuelve a darle atrás para salir de la app"),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
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
      ),
    );
  }
}