import 'package:cookbook/meals/ui/meal_detail_screen.dart';
import 'package:flutter/material.dart';

void goToMealDetail(BuildContext context, {required String mealId}) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => MealDetailScreen(mealId: mealId)),
  );
}
