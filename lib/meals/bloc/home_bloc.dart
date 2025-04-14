import 'dart:async';

import 'package:cookbook/common/util/data_status.dart';
import 'package:cookbook/common/util/event_transformer.dart';
import 'package:cookbook/meals/data/meal_repository.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Handles the current [HomeScreen] view (search, pager)
/// and handles the search of meals when the current view is set to search,
/// It uses sealed class and pattern types to represent and handle
/// to different view modes that have very different states.
/// While in pager mode we let the view handle its ephemeral state
/// in search mode we have support to show
/// - empty state with no previous query
/// - empty state due to no results
/// - failure state with support for retry
/// - loading
/// - success state
///
/// Here we also apply a debounce transformer to stop spamming the
/// API with unnecessary queries while the user is still typing.
class HomeBloc extends Bloc<HomeBlocEvent, HomeState> {
  HomeBloc(this.mealProvider) : super(PagerHomeState()) {
    on<UsePager>((event, emit) => emit(PagerHomeState()));
    on<UseSearch>((event, emit) {
      emit(
        SearchHomeState(
          status: DataStatus.success,
          results: [],
          lastQuery: null,
        ),
      );
    });
    on<SearchMeals>(
      _search,
      transformer: debounce(const Duration(milliseconds: 250)),
    );
  }

  final MealRepository mealProvider;

  Future<void> _search(SearchMeals event, Emitter<HomeState> emit) async {
    if (event.query.trim().isEmpty) return;
    switch (state) {
      case SearchHomeState(results: final oldResults):
        try {
          emit(
            SearchHomeState(
              status: DataStatus.loading,
              results: oldResults,
              lastQuery: event.query,
            ),
          );
          final newResults = await mealProvider.searchMealsByName(
            name: event.query.trim().toLowerCase(),
          );
          emit(
            SearchHomeState(
              status: DataStatus.success,
              results: newResults,
              lastQuery: event.query,
            ),
          );
        } catch (e, stackTrace) {
          debugPrintStack(
            stackTrace: stackTrace,
            label: "HomeBloc (_search): ",
          );
          emit(
            SearchHomeState(
              status: DataStatus.failure,
              results: [],
              lastQuery: event.query,
            ),
          );
        }
      default:
      // Impossible state
    }
  }
}

sealed class HomeBlocEvent {}

final class UsePager extends HomeBlocEvent {}

final class UseSearch extends HomeBlocEvent {}

final class SearchMeals extends HomeBlocEvent with EquatableMixin {
  final String query;

  SearchMeals({required this.query});

  @override
  List<Object?> get props => [query];
}

sealed class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class PagerHomeState extends HomeState {}

final class SearchHomeState extends HomeState {
  final DataStatus status;
  final List<Meal> results;
  final String? lastQuery;

  SearchHomeState({
    required this.status,
    required this.results,
    required this.lastQuery,
  });

  @override
  List<Object?> get props => [status, results];
}
