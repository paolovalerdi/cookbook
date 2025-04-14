import 'package:cookbook/common/components/empty.dart';
import 'package:cookbook/common/router.dart';
import 'package:cookbook/meals/bloc/favorites_bloc.dart';
import 'package:cookbook/meals/ui/components/meal_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoriteBlocState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child: switch (state) {
            FavoritesLoadingState() => Center(
              key: ValueKey("loading"),
              child: CircularProgressIndicator(),
            ),
            FavoritesFailureState() => Center(
              key: ValueKey("failed"),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Text("Ops! Something went wrong"),
                  FilledButton(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(LoadFavorites());
                    },
                    child: Text("Try again"),
                  ),
                ],
              ),
            ),
            FavoritesSuccessState(favorites: final favorites) =>
              favorites.isEmpty
                  ? Empty(label: "Begin by clicking the 🩷 button")
                  : ListView.builder(
                    padding: EdgeInsets.only(top: topInset, bottom: 32),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return MealListItem(
                        meal: favorites[index],
                        onTap: (value) {
                          goToMealDetail(context, mealId: value.id);
                        },
                      );
                    },
                  ),
          },
        );
      },
    );
  }
}
