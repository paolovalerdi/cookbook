import 'package:cookbook/meals/bloc/favorites_bloc.dart';
import 'package:cookbook/meals/ui/home_screen.dart';
import 'package:cookbook/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUpServiceLocator();

  runApp(const CookbookApp());
}

class CookbookApp extends StatelessWidget {
  const CookbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return FavoritesBloc(favoritesProvider: locator.get())
          ..add(LoadFavorites());
      },
      child: MaterialApp(
        title: 'Cookbook',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
            seedColor: Color(0xFFFFD50B),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
