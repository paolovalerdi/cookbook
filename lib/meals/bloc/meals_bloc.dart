import 'package:bloc/bloc.dart';
import 'package:cookbook/common/util/data_status.dart';
import 'package:cookbook/common/util/event_transformer.dart';
import 'package:cookbook/meals/data/meal_api.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:equatable/equatable.dart';

/// The main [Meal] least BLoC.
/// Since the API does not offer an endpoint that support pagination
/// this class implements a fake pagination exploiting the
/// "list all by first letter" feature.
/// Here we create a list of letter from a to z and
/// iterate trough them to create the pagination experience.
///
/// Exposes a state that can be rendered conditionally like
/// - Diplay a full screen loading spinner when the data is empty
/// - Display an appended loading spinner when there's data
class AllMealBloc extends Bloc<MealBlocEvent, MealsState> {
  AllMealBloc(this.api)
    : super(
        MealsState(status: DataStatus.loading, meals: [], hasReachedMax: false),
      ) {
    on<FetchMealsEvent>(
      _onFetch,
      transformer: throttleDroppable(Duration(milliseconds: 100)),
    );
  }

  final MealAPI api;

  int _currentPage = 0;
  final List<String> _alphabet = List.generate(
    26,
    (index) => String.fromCharCode(97 + index),
  );

  Future<void> _onFetch(
    FetchMealsEvent event,
    Emitter<MealsState> emitter,
  ) async {
    if (state.hasReachedMax) return;

    emitter(state.copyWith(status: DataStatus.loading));
    try {
      final meals = await api.fetchMealsByFirstLetter(
        letter: _alphabet[_currentPage],
      );

      emitter(
        state.copyWith(
          status: DataStatus.success,
          meals: [...state.meals, ...meals],
          hasReachedMax: _currentPage == _alphabet.length - 1,
        ),
      );

      _currentPage += 1;
    } catch (e) {
      _currentPage += 1;
      emitter(state.copyWith(status: DataStatus.failure));
    }
  }
}

sealed class MealBlocEvent {}

final class FetchMealsEvent extends MealBlocEvent {}

class MealsState extends Equatable {
  const MealsState({
    required this.status,
    required this.meals,
    required this.hasReachedMax,
  });

  final DataStatus status;
  final List<Meal> meals;
  final bool hasReachedMax;

  @override
  List<Object?> get props => [status, meals, hasReachedMax];

  MealsState copyWith({
    DataStatus? status,
    List<Meal>? meals,
    bool? hasReachedMax,
  }) {
    return MealsState(
      status: status ?? this.status,
      meals: meals ?? this.meals,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
