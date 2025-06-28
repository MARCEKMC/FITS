import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_search_result.dart';

class FoodSearchService {
  Future<List<FoodSearchResult>> searchFoods(String query) async {
    final url = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = List<Map<String, dynamic>>.from(data['products'] ?? []);
      return products
          .map((json) => FoodSearchResult.fromJson(json))
          .where((food) => food.name.isNotEmpty && food.kcal != null)
          .toList();
    } else {
      throw Exception('Error buscando alimentos');
    }
  }
}