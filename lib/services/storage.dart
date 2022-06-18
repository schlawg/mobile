import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:localstorage/localstorage.dart';

const keySessionId = 'sessionId';
const keyUserId = 'userId';
const keyPassword = 'password';

class Storage {
  String? get sessionId => get(keySessionId);
  set sessionId(String? sessionId) =>
      sessionId != null ? set(keySessionId, sessionId) : delete(keySessionId);

  String? get(String key) => _basic.get(key);
  Future<void> set(String key, String val) => _basic.set(key, val);

  double? getDouble(String key) => _basic.getDouble(key);
  Future<void> setDouble(String key, double val) => _basic.setDouble(key, val);

  int? getInt(String key) => _basic.getInt(key);
  Future<void> setInt(String key, int val) => _basic.setInt(key, val);

  Future<void> delete(String key) => _basic.delete(key);

  Future<void> init() async {
    _basic = PrefsStorage();
    await _basic.init();
  }

  Future<String?> secureGet(String key) async => _secure.read(key: key);

  Future<void> secureSet(String key, String val) async => _secure.write(key: key, value: val);

  Future<void> secureDelete(String key) async => _secure.delete(key: key);

  final _secure = const FlutterSecureStorage();
  late final PrefsStorage _basic;
}

// could use sqlite but keep it simple with sharedprefs/localstorage for now

class PrefsStorage {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get(String key) => _prefs.getString(key);
  Future<void> set(String key, String val) => _prefs.setString(key, val);

  double? getDouble(String key) => _prefs.getDouble(key);
  Future<void> setDouble(String key, double val) => _prefs.setDouble(key, val);

  int? getInt(String key) => _prefs.getInt(key);
  Future<void> setInt(String key, int val) => _prefs.setInt(key, val);

  Future<void> delete(String key) => _prefs.remove(key);
}

/*class FileStorage {
  final LocalStorage _store = LocalStorage('lichess.json');

  Future<void> init() async {}

  String? get(String key) => _store.getItem(key);
  Future<void> set(String key, String val) => _store.setItem(key, val);

  double? getDouble(String key) => _store.getItem(key);
  Future<void> setDouble(String key, double val) => _store.setItem(key, val);

  int? getInt(String key) => _store.getItem(key);
  Future<void> setInt(String key, int val) => _store.setItem(key, val);

  Future<void> delete(String key) => _store.deleteItem(key);
}*/
