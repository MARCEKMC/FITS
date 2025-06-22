import 'package:flutter/material.dart';
import 'package:fits/data/models/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ActivityCard({
    Key? key,
    required this.activity,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color get color {
    if (activity.category == "Trabajo") return Colors.blue[100]!;
    if (activity.category == "Estudios") return Colors.pink[100]!;
    if (activity.category == "Asuntos personales") return Colors.green[100]!;
    return Colors.grey[200]!;
  }

  void _showOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(ctx);
                if (onEdit != null) onEdit!();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                if (onDelete != null) onDelete!();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black26),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(10),
            right: Radius.circular(10),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          activity.title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black),
        ),
      ),
    );
  }
}