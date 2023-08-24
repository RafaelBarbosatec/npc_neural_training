import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/generation_manager.dart';
import 'package:npc_neural/game/components/knight.dart';
import 'package:npc_neural/game/neural_game.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:npc_neural/widgets/train_panel_widget.dart';

class NpcNeuralGame extends StatefulWidget {
  static const tilesize = 16.0;
  final SequentialWithVariation? neural;
  final bool train;
  final int individualsCount;
  const NpcNeuralGame({
    super.key,
    this.neural,
    this.train = true,
    this.individualsCount = 80,
  });

  static open(
    BuildContext context, {
    SequentialWithVariation? sequential,
    bool train = true,
    int individualsCount = 80,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NpcNeuralGame(
          neural: sequential,
          train: train,
          individualsCount:individualsCount,
        ),
      ),
    );
  }

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
      individualsCount: widget.individualsCount,
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
              training: false,
            ),
    );
  }
}
