import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/generation_manager.dart';
import 'package:npc_neural/game/components/knight.dart';
import 'package:npc_neural/game/neural_game.dart';
import 'package:npc_neural/widgets/train_panel_widget.dart';
import 'package:synadart/synadart.dart';

class NpcNeuralGame extends StatefulWidget {
  static const tilesize = 16.0;
  final Sequential? neural;
  final bool train;
  const NpcNeuralGame({super.key, this.neural, this.train = true});

  @override
  State<NpcNeuralGame> createState() => _NpcNeuralGameState();
}

class _NpcNeuralGameState extends State<NpcNeuralGame> {
  late GenerationManager _generationManager;
  BonfireGameInterface? game;
  @override
  void initState() {
    _generationManager = GenerationManager(
      storage: BonfireInjector().get(),
      baseNeural: widget.neural,
    );
    BonfireInjector.instance.putSingleton(
      (i) => _generationManager,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            TrainPanelWidget(
              withGraph: widget.train,
              onTapStart: _onStart,
            ),
            Expanded(
              child: NeuralGame(
                onReady: (value) {
                  game = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStart() {
    game?.add(
      widget.train
          ? _generationManager
          : Knight(
              position: GenerationManager.initPosition,
              neuralnetWork: widget.neural!,
              execNeural: true,
            ),
    );
  }
}
