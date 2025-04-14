import 'package:cookbook/meals/model/meal.dart';

Meal fakeMeal({required String id}) {
  return Meal(
    id: id,
    name: "",
    area: "",
    instructions: "",
    thumbnail: "",
    tags: [],
    ingredients: [],
    originalJson: {},
  );
}
