import 'package:cookbook/common/components/empty.dart';
import 'package:cookbook/common/components/glass_surface.dart';
import 'package:cookbook/common/router.dart';
import 'package:cookbook/common/styles/typography.dart';
import 'package:cookbook/common/util/data_status.dart';
import 'package:cookbook/meals/bloc/home_bloc.dart';
import 'package:cookbook/meals/bloc/meals_bloc.dart';
import 'package:cookbook/meals/ui/components/meal_list_item.dart';
import 'package:cookbook/meals/ui/favorites_page.dart';
import 'package:cookbook/meals/ui/meals_page.dart';
import 'package:cookbook/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum Tabs { meals, favorites }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeBloc(locator.get())),
        BlocProvider(
          create: (context) {
            return AllMealBloc(locator.get())..add(FetchMealsEvent());
          },
        ),
      ],
      child: HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final _pageController = PageController();
  final _focusNode = FocusNode();
  final _toolbarKey = GlobalKey();

  int _currentPage = 0;

  double _toolbarHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _toolbarHeight = _toolbarKey.currentContext?.size?.height ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPageChange(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocListener<HomeBloc, HomeState>(
            listenWhen: (previous, current) => current is PagerHomeState,
            listener: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                _pageController.jumpToPage(_currentPage);
              });
            },
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeInOutQuart,
                  switchOutCurve: Curves.easeInOutQuart,
                  child: switch (state) {
                    SearchHomeState() => SearchResults(
                      state: state,
                      topInset: _toolbarHeight,
                    ),
                    PagerHomeState() => PageView.builder(
                      controller: _pageController,
                      itemCount: Tabs.values.length,
                      onPageChanged: _onPageChange,
                      itemBuilder: (context, index) {
                        final tab = Tabs.values[index];
                        switch (tab) {
                          case Tabs.meals:
                            return MealsPage(topInset: _toolbarHeight);
                          case Tabs.favorites:
                            return FavoritesPage(topInset: _toolbarHeight);
                        }
                      },
                    ),
                  },
                );
              },
            ),
          ),
          GlassSurface(
            key: _toolbarKey,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return switch (state) {
                      SearchHomeState() => _SearchWidget(focusNode: _focusNode),
                      PagerHomeState() => Row(
                        spacing: 16,
                        children: [
                          for (final tab in Tabs.values)
                            GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  tab.index,
                                  duration: const Duration(milliseconds: 450),
                                  curve: Curves.easeInOutQuart,
                                );
                              },
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: TinosTextStyle(
                                  fontSize: 20,
                                  color:
                                      Tabs.values[_currentPage] == tab
                                          ? Colors.white
                                          : Colors.white24,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Text(tab.name.toUpperCase()),
                              ),
                            ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              context.read<HomeBloc>().add(UseSearch());
                              _focusNode.requestFocus();
                            },
                            child: Icon(LucideIcons.search),
                          ),
                        ],
                      ),
                    };
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchWidget extends StatefulWidget {
  const _SearchWidget({required this.focusNode});

  final FocusNode focusNode;

  @override
  State<_SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<_SearchWidget> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListenableBuilder(
                listenable: textController,
                builder: (context, child) {
                  return textController.text.isEmpty
                      ? child!
                      : SizedBox.shrink();
                },
                child: Text(
                  "Search...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
              EditableText(
                controller: textController,
                focusNode: widget.focusNode,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                cursorColor: Colors.white,
                backgroundCursorColor: Colors.white,
                onTapOutside: (event) {
                  widget.focusNode.unfocus();
                },
                onChanged: (value) {
                  context.read<HomeBloc>().add(SearchMeals(query: value));
                },
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.focusNode.unfocus();
            context.read<HomeBloc>().add(UsePager());
          },
          child: Icon(LucideIcons.x),
        ),
      ],
    );
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults({super.key, required this.state, required this.topInset});

  final SearchHomeState state;

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      DataStatus.failure => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text("Oops! Something went wrong"),
            FilledButton(
              onPressed: () {
                context.read<HomeBloc>().add(
                  SearchMeals(query: state.lastQuery ?? ""),
                );
              },
              child: Text("Try again"),
            ),
          ],
        ),
      ),
      DataStatus.loading => Center(
        child: Center(child: CircularProgressIndicator()),
      ),
      DataStatus.success =>
        state.lastQuery == null
            ? Center(child: Empty(icon: LucideIcons.search, label: "Search..."))
            : state.results.isEmpty
            ? Center(
              child: Empty(
                icon: LucideIcons.searchX,
                label: "No results found...",
              ),
            )
            : ListView.builder(
              itemCount: state.results.length,
              padding: EdgeInsets.only(top: topInset, bottom: 24),
              itemBuilder: (context, index) {
                return MealListItem(
                  meal: state.results[index],
                  onTap: (value) => goToMealDetail(context, mealId: value.id),
                );
              },
            ),
    };
  }
}
