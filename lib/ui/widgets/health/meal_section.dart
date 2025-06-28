import 'package:flutter/material.dart';
import '../../../data/models/food_search_result.dart'; 
import '../../../data/services/food_search_service.dart'; 

class MealSection extends StatelessWidget {
  final String mealName;
  final int calories;
  final Future<void> Function(String name, int kcal)? onAddFood; // callback para agregar alimento
  final List<Map<String, dynamic>> foods; // {id, name, kcal}
  final void Function(Map<String, dynamic> food)? onDelete;

  static const Map<String, IconData> mealIcons = {
    'Desayuno': Icons.breakfast_dining,
    'Media mañana': Icons.coffee,
    'Almuerzo': Icons.lunch_dining,
    'Lonche': Icons.bakery_dining,
    'Cena': Icons.nightlife,
    'Antojos': Icons.cake,
  };

  const MealSection({
    super.key,
    required this.mealName,
    required this.calories,
    required this.onAddFood,
    required this.foods,
    this.onDelete,
  });

  Future<void> _showFoodSearchDialog(BuildContext context) async {
    final service = FoodSearchService();
    final controller = TextEditingController();
    List<FoodSearchResult> results = [];
    bool loading = false;
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Colors.black12)),
            title: Text(
              'Buscar alimento para $mealName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del alimento',
                  ),
                  onSubmitted: (text) async {
                    setState(() {
                      loading = true;
                      error = null;
                    });
                    try {
                      final res = await service.searchFoods(text);
                      setState(() {
                        results = res;
                        loading = false;
                      });
                    } catch (e) {
                      setState(() {
                        error = 'Error al buscar alimentos';
                        loading = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                if (loading)
                  const CircularProgressIndicator(),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                if (!loading && results.isNotEmpty)
                  SizedBox(
                    height: 220,
                    width: 320,
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final food = results[i];
                        return ListTile(
                          title: Text(food.name),
                          subtitle: Text(
                            "Kcal: ${food.kcal?.toStringAsFixed(0) ?? '-'}, "
                            "C: ${food.carbs?.toStringAsFixed(1) ?? '-'}g, "
                            "P: ${food.protein?.toStringAsFixed(1) ?? '-'}g, "
                            "G: ${food.fat?.toStringAsFixed(1) ?? '-'}g",
                          ),
                          onTap: () async {
                            if (onAddFood != null) {
                              await onAddFood!(food.name, food.kcal?.round() ?? 0);
                            }
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = mealIcons[mealName] ?? Icons.restaurant_menu;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 1.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: Icon(icon, color: Colors.grey[800], size: 28),
          title: Row(
            children: [
              Text(
                mealName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '$calories kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          children: [
            if (foods.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Sin alimentos registrados",
                      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ...foods.map((food) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      food['name'],
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87),
                    ),
                  ),
                  Text(
                    "+${food['kcal']} kcal",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      tooltip: 'Eliminar alimento',
                      splashRadius: 20,
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            title: const Text(
                              "Eliminar alimento",
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              "¿Seguro que quieres eliminar \"${food['name']}\" de $mealName?",
                              style: const TextStyle(color: Colors.black87),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                ),
                                child: const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Eliminar"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          onDelete!(food);
                          // SnackBar minimalista
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Alimento eliminado',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: Colors.white,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Colors.black12),
                              ),
                              elevation: 5,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ]
                ],
              ),
            )),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: OutlinedButton.icon(
                  onPressed: () => _showFoodSearchDialog(context),
                  icon: const Icon(Icons.add, size: 20, color: Colors.black87),
                  label: const Text("Agregar alimento", style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    side: const BorderSide(color: Colors.black26),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}