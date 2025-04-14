import 'dart:convert';

import 'package:cookbook/meals/model/meal.dart';
import 'package:http/http.dart' as http;

/// Fetches data from a remote source and maps it into [Meal] objects
class MealAPI {
  MealAPI();

  static const String _baseUrl = "https://www.themealdb.com//api/json/v1/1";

  Future<List<Meal>> fetchMealsByFirstLetter({required String letter}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search.php?f=$letter'),
    );
    final Map<String, Object?> json = jsonDecode(response.body);

    final meals = json["meals"];

    if (meals is List) {
      return List<Meal>.unmodifiable(
        meals.map((itemJson) => Meal.fromJson(itemJson)),
      );
    }

    return [];
  }

  Future<List<Meal>> searchMealByName({required String name}) async {
    final response = await http.get(Uri.parse('$_baseUrl/search.php?s=$name'));
    final Map<String, Object?> json = jsonDecode(response.body);

    final meals = json["meals"];

    if (meals is List) {
      return List<Meal>.unmodifiable(
        meals.map((itemJson) => Meal.fromJson(itemJson)),
      );
    }

    return [];
  }

  Future<Meal?> fetchMealDetails({required String id}) async {
    final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));
    final Map<String, Object?> json = jsonDecode(response.body);

    final meals = json["meals"];

    if (meals is List) {
      return Meal.fromJson(meals.first);
    }

    return null;
  }
}
