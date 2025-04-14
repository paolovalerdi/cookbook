import 'package:bloc_test/bloc_test.dart';
import 'package:cookbook/meals/bloc/meal_detail_bloc.dart';
import 'package:cookbook/meals/data/favorites_repository.dart';
import 'package:cookbook/meals/data/meal_repository.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMealRepository extends Mock implements MealRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group('MealDetailBloc', () {
    late MockMealRepository mealRepo;
    late MockFavoritesRepository favRepo;
    const testMealId = 'abc123';
    final testMeal = Meal(
      id: testMealId,
      name: 'Test Meal',
      area: 'Test Area',
      instructions: 'Test Instructions',
      thumbnail: '',
      tags: [],
      ingredients: [],
      originalJson: {},
    );

    setUp(() {
      mealRepo = MockMealRepository();
      favRepo = MockFavoritesRepository();
    });

    blocTest<MealDetailBloc, MealDetailState>(
      'emits [Loading, Success] when meal is fetched successfully',
      build: () {
        when(
          () => mealRepo.getMealById(id: any(named: 'id')),
        ).thenAnswer((_) async => testMeal);
        when(() => favRepo.isFavorite(testMealId)).thenReturn(true);
        return MealDetailBloc(
          mealId: testMealId,
          mealProvider: mealRepo,
          favoritesProvider: favRepo,
        );
      },
      act: (bloc) => bloc.add(Load()),
      expect:
          () => [
            isA<Loading>(),
            isA<Sucess>()
                .having((s) => s.meal, 'meal', testMeal)
                .having((s) => s.favorite, 'favorite', true),
          ],
    );

    blocTest<MealDetailBloc, MealDetailState>(
      'emits [Loading, NoResult] when meal is not found',
      build: () {
        when(
          () => mealRepo.getMealById(id: any(named: 'id')),
        ).thenAnswer((_) async => null);
        return MealDetailBloc(
          mealId: testMealId,
          mealProvider: mealRepo,
          favoritesProvider: favRepo,
        );
      },
      act: (bloc) => bloc.add(Load()),
      expect: () => [isA<Loading>(), isA<NoResult>()],
    );

    blocTest<MealDetailBloc, MealDetailState>(
      'emits [Loading, Failed] when an exception is thrown',
      build: () {
        when(
          () => mealRepo.getMealById(id: any(named: 'id')),
        ).thenThrow(Exception('Failed to load'));
        return MealDetailBloc(
          mealId: testMealId,
          mealProvider: mealRepo,
          favoritesProvider: favRepo,
        );
      },
      act: (bloc) => bloc.add(Load()),
      skip: 1,
      expect: () => [isA<Failed>()],
    );

    blocTest<MealDetailBloc, MealDetailState>(
      'toggles favorite and emits updated Success',
      build: () {
        bool isFav = false;
        when(
          () => mealRepo.getMealById(id: any(named: 'id')),
        ).thenAnswer((_) async => testMeal);
        when(() => favRepo.isFavorite(testMealId)).thenAnswer((_) => isFav);
        when(() => favRepo.add(testMeal)).thenAnswer((_) async {
          isFav = true;
          return true;
        });

        return MealDetailBloc(
          mealId: testMealId,
          mealProvider: mealRepo,
          favoritesProvider: favRepo,
        );
      },
      seed: () => Sucess(meal: testMeal, favorite: false),
      act: (bloc) => bloc.add(ToggleFavorite()),
      wait: const Duration(milliseconds: 100),
      expect:
          () => [
            isA<Sucess>()
                .having((s) => s.meal, 'meal', testMeal)
                .having((s) => s.favorite, 'favorite', true),
          ],
      verify: (_) {
        verify(() => favRepo.add(testMeal)).called(1);
      },
    );
  });
}
