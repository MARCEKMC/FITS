import 'package:flutter/material.dart';

class FocusButton extends StatelessWidget {
  final VoidCallback? onTap;
  const FocusButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.2),
          elevation: 0,
        ),
        onPressed: onTap ?? () {},
        child: const Text('FOCUS'),
      ),
    );
  }
}