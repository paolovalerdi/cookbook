import 'package:bloc_test/bloc_test.dart';
import 'package:cookbook/meals/bloc/favorites_bloc.dart';
import 'package:cookbook/meals/data/favorites_repository.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_utils.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group('FavoritesBloc', () {
    late FavoritesRepository favoritesRepository;
    late List<Meal> testFavorites;

    setUp(() {
      favoritesRepository = MockFavoritesRepository();
      testFavorites = [fakeMeal(id: "pizza"), fakeMeal(id: "burguer")];
    });

    blocTest<FavoritesBloc, FavoriteBlocState>(
      'emits [FavoritesLoadingState, FavoritesSuccessState] when LoadFavorites is added and succeeds',
      build: () {
        when(() => favoritesRepository.favorites).thenReturn(testFavorites);
        return FavoritesBloc(favoritesProvider: favoritesRepository);
      },
      act: (bloc) => bloc.add(LoadFavorites()),
      expect:
          () => [
            isA<FavoritesLoadingState>(),
            isA<FavoritesSuccessState>().having(
              (s) => s.favorites,
              'favorites',
              testFavorites,
            ),
          ],
    );

    blocTest<FavoritesBloc, FavoriteBlocState>(
      'emits [FavoritesLoadingState, FavoritesFailureState] when LoadFavorites throws an exception',
      build: () {
        when(() => favoritesRepository.favorites).thenThrow(Exception('fail'));
        return FavoritesBloc(favoritesProvider: favoritesRepository);
      },
      act: (bloc) => bloc.add(LoadFavorites()),
      expect: () {
        return [isA<FavoritesLoadingState>(), isA<FavoritesFailureState>()];
      },
    );
  });
}
