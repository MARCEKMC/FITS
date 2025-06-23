import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black, // barra |
      selectionColor: Colors.black26, // color de selección de texto (fondo)
      selectionHandleColor: Colors.black, // las bolitas de selección
    ),
  );
}