import 'package:cookbook/common/components/empty.dart';
import 'package:cookbook/common/router.dart';
import 'package:cookbook/common/util/data_status.dart';
import 'package:cookbook/meals/bloc/meals_bloc.dart';
import 'package:cookbook/meals/ui/components/meal_list_item.dart';
import 'package:cookbook/meals/ui/components/youtube_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key, required this.topInset});

  final double topInset;

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      context.read<AllMealBloc>().add(FetchMealsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllMealBloc, MealsState>(
      builder: (context, state) {
        if (state.meals.isEmpty) {
          return switch (state.status) {
            DataStatus.loading => Center(child: CircularProgressIndicator()),
            DataStatus.failure => Center(
              child: FilledButton(
                onPressed:
                    () => context.read<AllMealBloc>()..add(FetchMealsEvent()),
                child: Text("Retry"),
              ),
            ),
            DataStatus.success => Empty(label: "We're just getting started"),
          };
        } else {
          final builders = <IndexedWidgetBuilder>[
            ...state.meals.map(
              (meal) => (context, _) {
                return MealListItem(
                  meal: meal,
                  onTap: (value) => goToMealDetail(context, mealId: value.id),
                );
              },
            ),
            switch (state.status) {
              DataStatus.loading => (_, _) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              DataStatus.success => (_, _) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child:
                        state.hasReachedMax
                            ? YoutubeButton(
                              url:
                                  "https://www.youtube.com/watch?v=A5Tuu6UnEe8",
                              label: "The End",
                            )
                            : SizedBox.shrink(),
                  ),
                );
              },
              DataStatus.failure => (_, _) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: FilledButton(onPressed: () {}, child: Text("Retry")),
                  ),
                );
              },
            },
          ];

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(top: widget.topInset, bottom: 24),
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: builders.length,
            itemBuilder: (context, index) => builders[index](context, index),
          );
        }
      },
    );
  }
}
