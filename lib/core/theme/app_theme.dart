import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    primaryColor: Colors.black,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
  );
}