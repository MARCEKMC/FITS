import 'package:flutter/material.dart';

class FilterModeDialog extends StatelessWidget {
  final String selected;
  const FilterModeDialog({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Ver por..."),
      children: [
        RadioListTile(
          title: const Text("Semanal"),
          value: "Semanal",
          groupValue: selected,
          onChanged: (_) => Navigator.pop(context, "Semanal"),
        ),
        RadioListTile(
          title: const Text("Mensual"),
          value: "Mensual",
          groupValue: selected,
          onChanged: (_) => Navigator.pop(context, "Mensual"),
        ),
      ],
    );
  }
}