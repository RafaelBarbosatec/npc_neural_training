import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:npc_neural/menu_page.dart';
import 'package:npc_neural/util/better_neural_listener.dart';
import 'package:npc_neural/util/strage.dart';
final getIt = GetIt.instance;

void main() {
  getIt.registerLazySingleton(
    () => BetterNeuralListener(),
  );
  getIt.registerLazySingleton(
    () => NeuralWeightsStorage(),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MenuPage(),
    );
  }
}
