import 'dart:convert';

import 'package:cookbook/common/kvstore/kvstore.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:flutter/foundation.dart';

/// A simple class that holds an in-memory cache
/// of [Meal]s that were marked as favorite and
/// encodes / decodes from / to a persistant key-value store.
class FavoritesRepository {
  FavoritesRepository({required this.kvStore}) {
    _init();
  }

  static const _storeKey = "favorites_provider";

  final KVStore kvStore;

  Map<String, Meal> _favorites = {};

  List<Meal> get favorites => List.unmodifiable(_favorites.values);

  bool isFavorite(String mealId) {
    return _favorites.containsKey(mealId);
  }

  Future<bool> add(Meal meal) async {
    try {
      _favorites[meal.id] = meal;
      await _commit();
      return true;
    } catch (e, stackTrace) {
      debugPrintStack(
        stackTrace: stackTrace,
        label: "FavoritesProvider (addToFavorites): ",
      );
      return false;
    }
  }

  Future<bool> remove(Meal meal) async {
    try {
      _favorites.remove(meal.id);
      await _commit();
      return true;
    } catch (e, stackTrace) {
      debugPrintStack(
        stackTrace: stackTrace,
        label: "FavoritesProvider (addToFavorites): ",
      );
      return false;
    }
  }

  Future<void> _init() async {
    try {
      final jsonString = await kvStore.getString(_storeKey);

      if (jsonString == null) return;

      final decoded = jsonDecode(jsonString) as List;
      final list = List<Map<String, Object?>>.from(decoded);

      _favorites = Map.fromEntries(
        list.map((json) {
          final meal = Meal.fromJson(json);
          return MapEntry(meal.id, meal);
        }),
      );
    } catch (e, stackTrace) {
      debugPrintStack(
        stackTrace: stackTrace,
        label: "FavoritesProvider (_init): ",
      );
    }
  }

  Future<void> _commit() {
    return kvStore.setString(
      _storeKey,
      jsonEncode(
        List.unmodifiable(_favorites.values.map((meal) => meal.toMap())),
      ),
    );
  }
}
