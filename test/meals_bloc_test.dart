import 'package:bloc_test/bloc_test.dart';
import 'package:cookbook/common/util/data_status.dart';
import 'package:cookbook/meals/bloc/meals_bloc.dart';
import 'package:cookbook/meals/data/meal_api.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_utils.dart';

class MockMealAPI extends Mock implements MealAPI {}

void main() {
  group('AllMealBloc', () {
    late MealAPI api;
    late List<Meal> mockMeals;

    setUp(() {
      api = MockMealAPI();
      mockMeals = [fakeMeal(id: '1'), fakeMeal(id: '2')];
    });

    test('initial state is loading with no meals and hasReachedMax false', () {
      final bloc = AllMealBloc(api);
      expect(bloc.state.status, DataStatus.loading);
      expect(bloc.state.meals, []);
      expect(bloc.state.hasReachedMax, isFalse);
    });

    blocTest<AllMealBloc, MealsState>(
      'emits [success] when fetch succeeds',
      build: () => AllMealBloc(api),
      setUp: () {
        when(
          () => api.fetchMealsByFirstLetter(letter: any(named: 'letter')),
        ).thenAnswer((_) async => mockMeals);
      },
      act: (bloc) => bloc.add(FetchMealsEvent()),
      wait: const Duration(milliseconds: 100),
      expect:
          () => [
            isA<MealsState>().having(
              (s) => s.status,
              'status',
              DataStatus.loading,
            ),
            isA<MealsState>()
                .having((s) => s.status, 'status', DataStatus.success)
                .having((s) => s.meals, 'meals', mockMeals),
          ],
    );

    blocTest<AllMealBloc, MealsState>(
      'emits [loading, failure] on error',
      build: () => AllMealBloc(api),
      setUp: () {
        when(
          () => api.fetchMealsByFirstLetter(letter: any(named: 'letter')),
        ).thenThrow(Exception('API error'));
      },
      act: (bloc) => bloc.add(FetchMealsEvent()),
      wait: const Duration(milliseconds: 100),
      expect:
          () => [
            isA<MealsState>().having(
              (s) => s.status,
              'status',
              DataStatus.loading,
            ),
            isA<MealsState>().having(
              (s) => s.status,
              'status',
              DataStatus.failure,
            ),
          ],
    );

    blocTest<AllMealBloc, MealsState>(
      'emits nothing when hasReachedMax is true',
      build: () => AllMealBloc(api),
      seed:
          () => MealsState(
            status: DataStatus.success,
            meals: mockMeals,
            hasReachedMax: true,
          ),
      act: (bloc) => bloc.add(FetchMealsEvent()),
      expect: () => [],
    );
  });
}
