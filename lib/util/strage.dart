import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NeuralWeightsStorage {
  Future save(String key, List<List<List<double>>> weights) async {
    final prefs = await _instance();
    prefs.setString(key, jsonEncode(weights));
  }

  Future<dynamic> get(String key) async {
    final prefs = await _instance();
    final json = prefs.getString(key);
    if (json != null) {
      return jsonDecode(json);
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
