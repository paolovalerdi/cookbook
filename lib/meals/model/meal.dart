import 'package:equatable/equatable.dart';

/// A simple representation of the data provided by TheMealDB
/// here we perform a couple of tricks like grouping
/// ingredients and measurements into a list of [Ingredient]
/// or grouping tags and category into a single list of tags
class Meal extends Equatable {
  const Meal({
    required this.id,
    required this.name,
    this.alternateName,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    this.youtubeUrl,
    required this.tags,
    required this.ingredients,
    required this.originalJson,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final tags = <String>{};

    if (json['strCategory'] != null &&
        json['strCategory'].toString().isNotEmpty) {
      tags.add(json['strCategory']);
    }

    if (json['strTags'] != null) {
      tags.addAll(
        json['strTags']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((tag) => tag.isNotEmpty),
      );
    }

    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim();
      final measure = json['strMeasure$i']?.toString().trim();

      if (ingredient != null &&
          ingredient.isNotEmpty &&
          measure != null &&
          measure.isNotEmpty) {
        ingredients.add(Ingredient(name: ingredient, measure: measure));
      }
    }

    return Meal(
      id: json['idMeal'],
      name: json['strMeal'],
      alternateName: json['strMealAlternate'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      thumbnail: json['strMealThumb'],
      youtubeUrl: json['strYoutube'],
      tags: tags.toList(),
      ingredients: ingredients,
      originalJson: json,
    );
  }

  final String id;
  final String name;
  final String? alternateName;
  final String area;
  final String instructions;
  final String thumbnail;
  final String? youtubeUrl;
  final List<String> tags;
  final List<Ingredient> ingredients;
  final Map<String, Object?> originalJson;

  @override
  List<Object?> get props => [id, name];

  Map<String, Object?> toMap() {
    return originalJson;
  }
}

class Ingredient extends Equatable {
  const Ingredient({required this.name, required this.measure});

  final String name;
  final String measure;

  String get thumbnail {
    return "https://www.themealdb.com/images/ingredients/${name.replaceAll(" ", "_")}.png";
  }

  @override
  List<Object?> get props => [name, measure];
}
