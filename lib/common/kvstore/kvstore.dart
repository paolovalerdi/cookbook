abstract class KVStore {
  Future<void> setString(String id, String value);
  Future<String?> getString(String id);
}
