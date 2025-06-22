import 'package:flutter/material.dart';

class CategoryManagerDialog extends StatefulWidget {
  final List<String> initialCategories;
  const CategoryManagerDialog({super.key, required this.initialCategories});

  @override
  State<CategoryManagerDialog> createState() => _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends State<CategoryManagerDialog> {
  late List<String> categories;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    categories = List.of(widget.initialCategories);
    super.initState();
  }

  void _addCategory() {
    final value = controller.text.trim();
    if (value.isNotEmpty && !categories.contains(value)) {
      setState(() {
        categories.add(value);
        controller.clear();
      });
    }
  }

  void _removeCategory(String cat) {
    setState(() {
      categories.remove(cat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Gestionar categorías"),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final cat in categories)
              Row(
                children: [
                  Expanded(child: Text(cat)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _removeCategory(cat),
                  ),
                ],
              ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Nueva categoría",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ),
              onSubmitted: (_) => _addCategory(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cerrar"),
          onPressed: () => Navigator.pop(context, categories),
        ),
      ],
    );
  }
}