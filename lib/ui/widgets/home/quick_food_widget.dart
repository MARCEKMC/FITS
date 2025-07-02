import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/food_search_result.dart';
import '../../../data/services/food_search_service.dart';
import '../../../modules/health/viewmodels/food_viewmodel.dart';
import '../../../shared/viewmodels/selected_date_viewmodel.dart';

class QuickFoodWidget extends StatelessWidget {
  final Function(String mealType) onMealTypeSelected;

  const QuickFoodWidget({
    super.key,
    required this.onMealTypeSelected,
  });

  Future<void> _showFoodSearchDialog(BuildContext context, String mealType) async {
    final service = FoodSearchService();
    final controller = TextEditingController();
    List<FoodSearchResult> results = [];
    bool loading = false;
    String? error;
    FoodSearchResult? selectedFood;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getMealIcon(mealType),
                          size: 20,
                          color: Colors.green[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agregar a $mealType',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Busca y selecciona un alimento',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Search field
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar alimento...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green[400]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: loading 
                          ? Container(
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                              ),
                            )
                          : IconButton(
                              onPressed: () async {
                                if (controller.text.trim().isEmpty) return;
                                
                                setState(() {
                                  loading = true;
                                  error = null;
                                });
                                
                                try {
                                  final res = await service.searchFoods(controller.text.trim());
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
                              icon: Icon(
                                Icons.search,
                                color: Colors.green[600],
                              ),
                            ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    onSubmitted: (text) async {
                      if (text.trim().isEmpty) return;
                      
                      setState(() {
                        loading = true;
                        error = null;
                      });
                      
                      try {
                        final res = await service.searchFoods(text.trim());
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
                  
                  const SizedBox(height: 16),
                  
                  // Error message
                  if (error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error!,
                              style: TextStyle(color: Colors.red[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Results
                  if (results.isNotEmpty) ...[
                    Text(
                      'Resultados de búsqueda:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final food = results[i];
                          final isSelected = selectedFood?.name == food.name;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green[50] : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.green[300]! : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                food.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.green[700] : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                "Kcal: ${food.kcal?.toStringAsFixed(0) ?? '-'} | "
                                "C: ${food.carbs?.toStringAsFixed(1) ?? '-'}g | "
                                "P: ${food.protein?.toStringAsFixed(1) ?? '-'}g | "
                                "G: ${food.fat?.toStringAsFixed(1) ?? '-'}g",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.green[600] : Colors.grey[600],
                                ),
                              ),
                              trailing: isSelected 
                                  ? Icon(Icons.check_circle, color: Colors.green[600])
                                  : null,
                              onTap: () {
                                setState(() {
                                  selectedFood = food;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ] else if (controller.text.isNotEmpty && !loading) ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Busca un alimento para comenzar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Escribe el nombre de un alimento',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  // Action buttons
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedFood != null 
                              ? () async {
                                  try {
                                    final foodVM = Provider.of<FoodViewModel>(context, listen: false);
                                    final selectedDateVM = Provider.of<SelectedDateViewModel>(context, listen: false);
                                    
                                    await foodVM.addFoodEntry(
                                      mealType,
                                      selectedFood!.name,
                                      selectedFood!.kcal?.round() ?? 0,
                                      selectedDateVM.selectedDate,
                                      carbs: selectedFood!.carbs,
                                      protein: selectedFood!.protein,
                                      fat: selectedFood!.fat,
                                    );
                                    
                                    Navigator.of(ctx).pop();
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${selectedFood!.name} agregado a $mealType'),
                                          backgroundColor: Colors.green[600],
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al agregar alimento: $e'),
                                          backgroundColor: Colors.red[600],
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedFood != null ? Colors.green[600] : Colors.grey[300],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Agregar',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Desayuno': return Icons.wb_sunny;
      case 'Media Mañana': return Icons.coffee;
      case 'Almuerzo': return Icons.lunch_dining;
      case 'Lonche': return Icons.bakery_dining;
      case 'Cena': return Icons.dinner_dining;
      case 'Antojo': return Icons.cake;
      default: return Icons.restaurant_menu;
    }
  }

  Widget _buildMealButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 24,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registrar Comida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Selecciona el tipo de comida',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Primera fila de comidas
            Row(
              children: [
                _buildMealButton(
                  title: 'Desayuno',
                  icon: Icons.wb_sunny,
                  color: Colors.orange[600]!,
                  onTap: () => _showFoodSearchDialog(context, 'Desayuno'),
                ),
                const SizedBox(width: 8),
                _buildMealButton(
                  title: 'Media Mañana',
                  icon: Icons.coffee,
                  color: Colors.brown[600]!,
                  onTap: () => _showFoodSearchDialog(context, 'Media mañana'),
                ),
                const SizedBox(width: 8),
                _buildMealButton(
                  title: 'Almuerzo',
                  icon: Icons.lunch_dining,
                  color: Colors.red[600]!,
                  onTap: () => _showFoodSearchDialog(context, 'Almuerzo'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Segunda fila de comidas
            Row(
              children: [
                _buildMealButton(
                  title: 'Lonche',
                  icon: Icons.bakery_dining,
                  color: Colors.purple[600]!,
                  onTap: () => _showFoodSearchDialog(context, 'Lonche'),
                ),
                const SizedBox(width: 8),
                _buildMealButton(
                  title: 'Cena',
                  icon: Icons.dinner_dining,
                  color: Colors.indigo[600]!,
                  onTap: () => _showFoodSearchDialog(context, 'Cena'),
                ),
                const SizedBox(width: 8),
                _buildMealButton(
                  title: 'Antojo',
                  icon: Icons.cake,
                  color: Colors.pink[600]!,
                  onTap: () => _showFoodSearchDialog(context, 'Antojos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
