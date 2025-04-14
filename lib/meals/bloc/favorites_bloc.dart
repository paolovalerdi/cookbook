import 'package:bloc/bloc.dart';
import 'package:cookbook/common/util/event_transformer.dart';
import 'package:cookbook/meals/data/favorites_repository.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:equatable/equatable.dart';

/// The BloC that provides the list of favorite meals
/// to the [FavoritesPage] view.
/// It simply exposes an event to load the favorites and
/// a sealed class that represents loading, failure, success states.
class FavoritesBloc extends Bloc<FavoritesBlocEvent, FavoriteBlocState> {
  FavoritesBloc({required this.favoritesProvider})
    : super(FavoritesLoadingState()) {
    on<LoadFavorites>(
      _load,
      transformer: throttleDroppable(Duration(milliseconds: 100)),
    );
  }

  final FavoritesRepository favoritesProvider;

  Future<void> _load(
    LoadFavorites event,
    Emitter<FavoriteBlocState> emit,
  ) async {
    emit(FavoritesLoadingState());
    try {
      emit(FavoritesSuccessState(favorites: favoritesProvider.favorites));
    } catch (e) {
      emit(FavoritesFailureState());
    }
  }
}

sealed class FavoritesBlocEvent {}

final class LoadFavorites extends FavoritesBlocEvent {}

sealed class FavoriteBlocState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FavoritesLoadingState extends FavoriteBlocState {}

final class FavoritesFailureState extends FavoriteBlocState {}

final class FavoritesSuccessState extends FavoriteBlocState {
  FavoritesSuccessState({required this.favorites});

  final List<Meal> favorites;

  @override
  List<Object?> get props => [favorites];
}
