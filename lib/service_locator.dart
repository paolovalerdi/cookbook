import 'package:cookbook/common/kvstore/device_kvstore.dart';
import 'package:cookbook/common/kvstore/kvstore.dart';
import 'package:cookbook/meals/data/favorites_repository.dart';
import 'package:cookbook/meals/data/meal_api.dart';
import 'package:cookbook/meals/data/meal_repository.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setUpServiceLocator() {
  locator.registerSingleton(MealAPI());
  locator.registerSingleton<KVStore>(DeviceKVStore());
  locator.registerSingleton(MealRepository(api: locator.get()));
  locator.registerSingleton(FavoritesRepository(kvStore: locator.get()));
}
