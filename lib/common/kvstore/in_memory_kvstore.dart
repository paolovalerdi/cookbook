import 'package:cookbook/common/kvstore/kvstore.dart';

class InMemoryKVStore extends KVStore {
  final Map<String, Object> _data = {};

  @override
  Future<String?> getString(String id) async {
    return _data[id] as String?;
  }

  @override
  Future<void> setString(String id, String value) async {
    _data[id] = value;
  }
}
