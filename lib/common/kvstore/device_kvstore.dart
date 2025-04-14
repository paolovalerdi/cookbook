import 'package:cookbook/common/kvstore/kvstore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceKVStore extends KVStore {
  final _prefs = SharedPreferencesAsync();

  @override
  Future<String?> getString(String id) {
    return _prefs.getString(id);
  }

  @override
  Future<void> setString(String id, String value) {
    return _prefs.setString(id, value);
  }
}
