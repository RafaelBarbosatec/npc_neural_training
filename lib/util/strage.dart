import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:synadart/synadart.dart';

class NeuralStorage {
  Future save(String key, Sequential neural) async {
    final prefs = await _instance();
    prefs.setString(key, jsonEncode(neural.toMap()));
  }

  Future<Sequential?> get(String key) async {
    final prefs = await _instance();
    final json = prefs.getString(key);
    if (json != null) {
      return Sequential.fromMap(jsonDecode(json));
    }
    return null;
  }

  Future delete(String key) async {
    final prefs = await _instance();
    prefs.remove(key);
  }

  Future clear() async {
    final prefs = await _instance();
    return prefs.clear();
  }

  Future<Set<String>> getKeys() async {
    final prefs = await _instance();
    return prefs.getKeys();
  }

  Future<SharedPreferences> _instance() {
    return SharedPreferences.getInstance();
  }
}
