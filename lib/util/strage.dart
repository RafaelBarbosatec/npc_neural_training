import 'dart:convert';

import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NeuralStorage {
  Future save(String key, SequentialWithVariation neural) async {
    final prefs = await _instance();
    prefs.setString(key, jsonEncode(neural.toMap()));
  }

  Future<SequentialWithVariation?> get(String key) async {
    final prefs = await _instance();
    final json = prefs.getString(key);
    if (json != null) {
      return SequentialWithVariation.fromMap(jsonDecode(json));
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
