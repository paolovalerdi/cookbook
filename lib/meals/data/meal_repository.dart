import 'package:cookbook/meals/data/meal_api.dart';
import 'package:cookbook/meals/model/meal.dart';

/// This repository is even simpler, it holds a very
/// basic in-memory cache of the [Meals]s the user requested details of
/// so the next time they request the same [Meal] we can fulfill the request
/// instantly instead of hitting the remote data source
class MealRepository {
  MealRepository({required this.api});

  final MealAPI api;

  final _cache = <String, Meal>{};

  Future<Meal?> getMealById({required String id}) async {
    final cached = _cache[id];

    if (cached != null) return cached;

    try {
      final remote = await api.fetchMealDetails(id: id);

      if (remote == null) return null;

      _cache[id] = remote;
      return remote;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Meal>> getMealsByFirstLetter({required String letter}) {
    return api.fetchMealsByFirstLetter(letter: letter);
  }

  Future<List<Meal>> searchMealsByName({required String name}) {
    return api.searchMealByName(name: name);
  }
}
