// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:cookbook/common/components/empty.dart';
import 'package:cookbook/common/components/glass_surface.dart';
import 'package:cookbook/common/styles/typography.dart';
import 'package:cookbook/common/util/context_x.dart';
import 'package:cookbook/meals/bloc/favorites_bloc.dart';
import 'package:cookbook/meals/bloc/meal_detail_bloc.dart';
import 'package:cookbook/meals/model/meal.dart';
import 'package:cookbook/meals/ui/components/labeled_widget.dart';
import 'package:cookbook/meals/ui/components/youtube_button.dart';
import 'package:cookbook/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key, required this.mealId});

  final String mealId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return MealDetailBloc(
          mealId: mealId,
          mealProvider: locator.get(),
          favoritesProvider: locator.get(),
        )..add(Load());
      },
      child: Scaffold(
        body: BlocBuilder<MealDetailBloc, MealDetailState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: switch (state) {
                Sucess(meal: final meal, favorite: final favorite) =>
                  _MealDetailScreenContent(meal: meal, favorite: favorite),
                Loading() => Center(
                  key: ValueKey("loading"),
                  child: CircularProgressIndicator(),
                ),
                Failed() => Center(
                  key: ValueKey("failed"),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Ops! Somethin went wrong"),
                      FilledButton(
                        onPressed: () {
                          context.read<MealDetailBloc>().add(Load());
                        },
                        child: Text("Try again"),
                      ),
                    ],
                  ),
                ),
                NoResult() => Center(
                  key: ValueKey("empty"),
                  child: Empty(label: "Such empty"),
                ),
              },
            );
          },
        ),
      ),
    );
  }
}

enum _ContentView { instructions, ingredients }

class _MealDetailScreenContent extends StatefulWidget {
  const _MealDetailScreenContent({required this.meal, required this.favorite});

  final Meal meal;
  final bool favorite;

  @override
  State<_MealDetailScreenContent> createState() =>
      _MealDetailScreenContentState();
}

class _MealDetailScreenContentState extends State<_MealDetailScreenContent> {
  final _imageKey = GlobalKey();
  final _titleKey = GlobalKey();
  final _toolbarKey = GlobalKey();

  final _scrollController = ScrollController();

  double _titleBottom = 0;
  double _toolbarBottom = 0;

  List<String> _instructions = [];

  _ContentView _contentView = _ContentView.instructions;

  @override
  void initState() {
    super.initState();
    setState(() {
      _instructions = List.unmodifiable(
        widget.meal.instructions
            .split("\r\n")
            .map((it) => it.trim())
            .where((it) => it.isNotEmpty && it.length > 1),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _titleBottom = _titleKey.currentContext?.globalPaintBounds.bottom ?? 0;
        _toolbarBottom =
            _toolbarKey.currentContext?.globalPaintBounds.bottom ?? 0;
      });
    });
  }

  void _switchView(_ContentView view) {
    setState(() {
      _contentView = view;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: _toolbarBottom,
              bottom: MediaQuery.of(context).viewPadding.bottom,
            ),
            children: [
              AspectRatio(
                key: _imageKey,
                aspectRatio: 4 / 3,
                child: Image.network(widget.meal.thumbnail, fit: BoxFit.cover),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        key: _titleKey,
                        widget.meal.name,
                        style: TinosTextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      color: Colors.pinkAccent.shade100,
                      onPressed: () {
                        context.read<MealDetailBloc>().add(ToggleFavorite());
                        context.read<FavoritesBloc>().add(LoadFavorites());
                      },
                      icon: Icon(
                        widget.favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    LabeledWidget(
                      icon: Icon(
                        LucideIcons.earth,
                        size: 16,
                        color: Colors.greenAccent,
                      ),
                      text: widget.meal.area,
                    ),
                    LabeledWidget(
                      icon: Icon(LucideIcons.tags, size: 16),
                      text: widget.meal.tags.join(", "),
                    ),
                    if (widget.meal.youtubeUrl != null)
                      YoutubeButton(url: widget.meal.youtubeUrl!),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  spacing: 16,
                  children: [
                    for (final view in _ContentView.values)
                      GestureDetector(
                        onTap: () => _switchView(view),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TinosTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                view == _contentView
                                    ? Colors.white
                                    : Colors.white24,
                          ),
                          child: Text(view.name.toUpperCase()),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (_contentView == _ContentView.instructions)
                ..._instructions.mapIndexed<Widget>((index, step) {
                  return Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${index + 1}. ",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          TextSpan(text: step),
                        ],
                      ),
                    ),
                  );
                })
              else if (_contentView == _ContentView.ingredients) ...[
                ...widget.meal.ingredients.map(
                  (e) => _IngredientItem(ingredient: e),
                ),
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            child: GlassSurface(
              key: _toolbarKey,
              child: Stack(
                children: [
                  ColoredBox(
                    color: Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0.6),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 20, 16),
                        child: Row(
                          spacing: 12,
                          children: [
                            Icon(LucideIcons.chevronLeft),
                            Expanded(
                              child: ListenableBuilder(
                                listenable: _scrollController,
                                builder: (context, child) {
                                  if (!_scrollController.hasClients) {
                                    return child!;
                                  }
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      (_titleBottom - _scrollController.offset)
                                          .clamp(0, _toolbarBottom),
                                    ),
                                    child: child,
                                  );
                                },
                                child: Text(
                                  widget.meal.name,
                                  style: TinosTextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 48,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: Navigator.of(context).maybePop,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  const _IngredientItem({required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        spacing: 16,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.square(
              dimension: 60,
              child: Image.network(ingredient.thumbnail),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ingredient.measure,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextSpan(text: " ${ingredient.name}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
