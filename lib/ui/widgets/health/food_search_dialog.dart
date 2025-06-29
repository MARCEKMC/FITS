import 'package:flutter/material.dart';
import '../../data/models/food_search_result.dart';
import '../../data/services/food_search_service.dart';

class FoodSearchDialog extends StatefulWidget {
  final void Function(FoodSearchResult)? onFoodSelected;

  const FoodSearchDialog({super.key, this.onFoodSelected});

  @override
  State<FoodSearchDialog> createState() => _FoodSearchDialogState();
}

class _FoodSearchDialogState extends State<FoodSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  final FoodSearchService _service = FoodSearchService();
  List<FoodSearchResult> _results = [];
  bool _loading = false;
  String? _error;

  void _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await _service.searchFoods(query);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al buscar alimentos';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar alimento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre del alimento',
            ),
            onSubmitted: _search,
          ),
          const SizedBox(height: 10),
          if (_loading) const CircularProgressIndicator(),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          if (!_loading && _results.isNotEmpty)
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final food = _results[i];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                        "Kcal: ${food.kcal?.toStringAsFixed(0) ?? '-'}, "
                        "C: ${food.carbs?.toStringAsFixed(1) ?? '-'}g, "
                        "P: ${food.protein?.toStringAsFixed(1) ?? '-'}g, "
                        "G: ${food.fat?.toStringAsFixed(1) ?? '-'}g"),
                    onTap: () {
                      widget.onFoodSelected?.call(food);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}