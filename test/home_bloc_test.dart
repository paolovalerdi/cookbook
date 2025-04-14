import 'package:bloc_test/bloc_test.dart';
import 'package:cookbook/common/util/data_status.dart';
import 'package:cookbook/meals/bloc/home_bloc.dart';
import 'package:cookbook/meals/data/meal_repository.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_utils.dart';

class MockMealRepository extends Mock implements MealRepository {}

void main() {
  group('HomeBloc', () {
    late MealRepository mealRepository;
    late List<Meal> searchResults;

    setUp(() {
      mealRepository = MockMealRepository();
      searchResults = [fakeMeal(id: "sushi"), fakeMeal(id: "tacos")];
    });

    test('initial state is PagerHomeState', () {
      final bloc = HomeBloc(mealRepository);
      expect(bloc.state, isA<PagerHomeState>());
    });

    blocTest<HomeBloc, HomeState>(
      'emits [PagerHomeState] when UsePager is added',
      build: () => HomeBloc(mealRepository),
      act: (bloc) => bloc.add(UsePager()),
      expect: () => [isA<PagerHomeState>()],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [SearchHomeState with empty results] when UseSearch is added',
      build: () => HomeBloc(mealRepository),
      act: (bloc) => bloc.add(UseSearch()),
      expect:
          () => [
            predicate<HomeState>((state) {
              return state is SearchHomeState &&
                  state.status == DataStatus.success &&
                  state.results.isEmpty &&
                  state.lastQuery == null;
            }),
          ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, success] when SearchMeals succeeds',
      build: () => HomeBloc(mealRepository),
      seed:
          () => SearchHomeState(
            status: DataStatus.success,
            results: [],
            lastQuery: null,
          ),
      setUp: () {
        when(
          () => mealRepository.searchMealsByName(name: any(named: 'name')),
        ).thenAnswer((_) async => searchResults);
      },
      act: (bloc) => bloc.add(SearchMeals(query: 'sushi')),
      wait: const Duration(milliseconds: 300),
      expect:
          () => [
            isA<SearchHomeState>()
                .having((s) => s.status, 'status', DataStatus.loading)
                .having((s) => s.lastQuery, 'lastQuery', 'sushi'),
            isA<SearchHomeState>()
                .having((s) => s.status, 'status', DataStatus.success)
                .having((s) => s.results, 'results', searchResults)
                .having((s) => s.lastQuery, 'lastQuery', 'sushi'),
          ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, failure] when SearchMeals throws an exception',
      build: () => HomeBloc(mealRepository),
      seed:
          () => SearchHomeState(
            status: DataStatus.success,
            results: [],
            lastQuery: null,
          ),
      setUp: () {
        when(
          () => mealRepository.searchMealsByName(name: any(named: 'name')),
        ).thenThrow(Exception('error'));
      },
      act: (bloc) => bloc.add(SearchMeals(query: 'invalid')),
      wait: const Duration(milliseconds: 300),
      expect:
          () => [
            isA<SearchHomeState>()
                .having((s) => s.status, 'status', DataStatus.loading)
                .having((s) => s.lastQuery, 'lastQuery', 'invalid'),
            isA<SearchHomeState>()
                .having((s) => s.status, 'status', DataStatus.failure)
                .having((s) => s.results, 'results', [])
                .having((s) => s.lastQuery, 'lastQuery', 'invalid'),
          ],
    );
  });
}
