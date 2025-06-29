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

  // Mensajes cortos, siempre dos líneas, ambos centrados y mismo color
  String _msgLine1 = "Bienvenido a FITS";
  String _msgLine2 = "Inicia sesión aquí";

  bool _obscureText = true;

  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  void _setMessage(String l1, String l2) {
    setState(() {
      _msgLine1 = l1;
      _msgLine2 = l2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 380 ? 350.0 : width;
    const double separatorSpacing = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // ¡IMPORTANTE!
      body: Stack(
        children: [
          Center(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título elegante mayúsculas
                  Text(
                    "INICIAR SESIÓN",
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.2,
                      color: Colors.black.withOpacity(0.96),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Card de login
                  Container(
                    width: cardWidth,
                    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 21),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.black12, width: 1.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Usuario o email
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "Usuario o Email",
                            labelStyle: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(color: Colors.black12, width: 1.1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(color: Colors.black12, width: 1.1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(color: Colors.black87, width: 1.4),
                            ),
                            hintText: "ejemplo@email.com",
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Contraseña
                        TextField(
                          controller: _passController,
                          obscureText: _obscureText,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            labelStyle: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(color: Colors.black12, width: 1.1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(color: Colors.black12, width: 1.1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                              borderSide: const BorderSide(color: Colors.black87, width: 1.4),
                            ),
                            hintText: "Tu contraseña",
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.black38,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        // Botón ingresar
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: _loading
                                ? null
                                : () async {
                                    final email = _emailController.text.trim();
                                    final pass = _passController.text.trim();

                                    // Validaciones previas
                                    if (email.isEmpty || pass.isEmpty) {
                                      _setMessage(
                                        "Completa todos los",
                                        "campos para continuar"
                                      );
                                      return;
                                    }
                                    if (!_isValidEmail(email)) {
                                      _setMessage(
                                        "Correo no válido",
                                        "Revisa el formato"
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _loading = true;
                                    });
                                    try {
                                      final user = await authViewModel.signInWithEmail(email, pass);
                                      if (user != null) {
                                        await user.reload();
                                        if (user.emailVerified) {
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
                                      final err = e.toString().toLowerCase();
                                      if (err.contains("contraseña incorrecta") ||
                                          err.contains("wrong-password")) {
                                        _setMessage(
                                          "Contraseña incorrecta",
                                          "Inténtalo otra vez"
                                        );
                                      } else if (err.contains("usuario no encontrado") ||
                                                 err.contains("user-not-found")) {
                                        _setMessage(
                                          "Usuario no encontrado",
                                          "Verifica tu correo"
                                        );
                                      } else if (err.contains("usuario deshabilitado") ||
                                                 err.contains("user-disabled")) {
                                        _setMessage(
                                          "Cuenta deshabilitada",
                                          "Contacta a soporte"
                                        );
                                      } else {
                                        _setMessage(
                                          "Error al iniciar sesión",
                                          "Inténtalo de nuevo"
                                        );
                                      }
                                    }
                                    setState(() => _loading = false);
                                  },
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text("Ingresar"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: separatorSpacing),
                  // "O INICIA SESIÓN CON" centrado y líneas dentro del ancho del card
                  SizedBox(
                    width: cardWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.black.withOpacity(0.16),
                            thickness: 1.1,
                            endIndent: 10,
                          ),
                        ),
                        const Text(
                          "O INICIA SESIÓN CON",
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.black54,
                            letterSpacing: 1,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black.withOpacity(0.16),
                            thickness: 1.1,
                            indent: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: separatorSpacing),
                  // Botones sociales (alineados al marco)
                  Container(
                    width: cardWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.facebook, color: Colors.black, size: 20),
                            label: const Text(
                              "Facebook",
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black12, width: 1.1),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
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
                                _setMessage(
                                  "Error con Facebook",
                                  "Intenta más tarde"
                                );
                              }
                              setState(() => _loading = false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.g_mobiledata, color: Colors.black, size: 21),
                            label: const Text(
                              "Google",
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black12, width: 1.1),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
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
                                _setMessage(
                                  "Error con Google",
                                  "Intenta más tarde"
                                );
                              }
                              setState(() => _loading = false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Dibujo + cuadro de mensaje mejorados
                  SizedBox(
                    width: cardWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Dibujo grande
                        Image.asset(
                          'lib/core/utils/images/char_error.png',
                          height: 120,
                          fit: BoxFit.fitHeight,
                        ),
                        const SizedBox(width: 16),
                        // Cuadro de mensaje: SIEMPRE dos líneas, mismo color, corto, centrado vertical y centrado el texto
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 45),
                            height: 90,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.black12, width: 1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _msgLine1,
                                  style: const TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _msgLine2,
                                  style: const TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
          // --- DESLIZA PARA REGISTRARTE abajo a la derecha, pero un poco más arriba ---
          Positioned(
            bottom: 42,
            right: 26,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "DESLIZA PARA REGISTRARTE ",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                Transform.rotate(
                  angle: 0,
                  child: Icon(
                    Icons.play_arrow,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}