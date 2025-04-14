import 'dart:async';

import 'package:cookbook/common/util/event_transformer.dart';
import 'package:cookbook/meals/data/favorites_repository.dart';
import 'package:cookbook/meals/data/meal_repository.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Handles fetching the details of a [Meal] and updating
/// the "is favorite" state.
/// It simply exposes an event to toggle the favorite state
/// and handles all the necessary mutation internally.
class MealDetailBloc extends Bloc<MealDetailEvent, MealDetailState> {
  MealDetailBloc({
    required this.mealId,
    required this.mealProvider,
    required this.favoritesProvider,
  }) : super(Loading()) {
    on<ToggleFavorite>(
      _toggleFavorite,
      transformer: throttleDroppable(Duration(milliseconds: 100)),
    );
    on<Load>(_load);
  }

  final MealRepository mealProvider;
  final FavoritesRepository favoritesProvider;
  final String mealId;

  Future<void> _load(Load event, Emitter<MealDetailState> emit) async {
    try {
      emit(Loading());

      final meal = await mealProvider.getMealById(id: mealId);

      if (meal == null) {
        emit(NoResult());
        return;
      }

      emit(Sucess(meal: meal, favorite: favoritesProvider.isFavorite(mealId)));
    } catch (e, stackTrace) {
      debugPrintStack(
        stackTrace: stackTrace,
        label: "MealDetailBlock (_load): ",
      );
      emit(Failed());
    }
  }

  FutureOr<void> _toggleFavorite(
    ToggleFavorite event,
    Emitter<MealDetailState> emit,
  ) async {
    switch (state) {
      case Sucess(meal: final meal):
        try {
          if (favoritesProvider.isFavorite(mealId)) {
            await favoritesProvider.remove(meal);
          } else {
            await favoritesProvider.add(meal);
          }
          emit(
            Sucess(meal: meal, favorite: favoritesProvider.isFavorite(mealId)),
          );
        } catch (e, stackTrace) {
          debugPrintStack(
            stackTrace: stackTrace,
            label: "MealDetailBloc (_toggleFavorite): ",
          );
        }
      default:
    }
  }
}

sealed class MealDetailEvent {}

final class Load extends MealDetailEvent {}

final class ToggleFavorite extends MealDetailEvent {}

sealed class MealDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class Loading extends MealDetailState {}

final class Failed extends MealDetailState {}

final class NoResult extends MealDetailState {}

final class Sucess extends MealDetailState {
  Sucess({required this.meal, required this.favorite});

  final Meal meal;
  final bool favorite;

  @override
  List<Object?> get props => [meal, favorite];
}
