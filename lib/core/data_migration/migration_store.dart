import 'package:shared_preferences/shared_preferences.dart';

abstract interface class MigrationStore {
  Set<String> get keys;

  Object? read(String key);

  Future<void> writeInt(String key, int value);

  Future<void> writeString(String key, String value);

  Future<void> writeStringList(String key, List<String> value);

  Future<void> remove(String key);
}

class SharedPreferencesMigrationStore implements MigrationStore {
  SharedPreferencesMigrationStore(this.preferences);

  final SharedPreferences preferences;

  @override
  Set<String> get keys => preferences.getKeys();

  @override
  Object? read(String key) => preferences.get(key);

  @override
  Future<void> writeInt(String key, int value) async {
    if (!await preferences.setInt(key, value)) {
      throw StateError('Failed to write an integer migration value.');
    }
  }

  @override
  Future<void> writeString(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('Failed to write a string migration value.');
    }
  }

  @override
  Future<void> writeStringList(String key, List<String> value) async {
    if (!await preferences.setStringList(key, value)) {
      throw StateError('Failed to write a list migration value.');
    }
  }

  @override
  Future<void> remove(String key) async {
    if (!keys.contains(key)) return;
    if (!await preferences.remove(key)) {
      throw StateError('Failed to remove a migration value.');
    }
  }
}
