import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/generation_manager.dart';
import 'package:npc_neural/game/components/knight.dart';
import 'package:npc_neural/game/components/spikes_line.dart';
import 'package:npc_neural/game/neural_game.dart';
import 'package:npc_neural/main.dart';
import 'package:npc_neural/neural_network_utils/models.dart';
import 'package:npc_neural/widgets/train_panel_widget.dart';

class NpcNeuralGame extends StatefulWidget {
  static const tilesize = 16.0;
  final SequentialWithVariation? projenitorNeural;
  final bool train;
  final int individualsCount;
  final double mutationPercent;
  const NpcNeuralGame({
    super.key,
    this.projenitorNeural,
    this.train = true,
    this.individualsCount = 80,
    this.mutationPercent = 1.0,
  });

  static open({
    required BuildContext context,
    SequentialWithVariation? projenitorNeural,
    bool train = true,
    int individualsCount = 80,
    double mutationPercent = 1.0,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NpcNeuralGame(
          projenitorNeural: projenitorNeural,
          train: train,
          individualsCount: individualsCount,
          mutationPercent: mutationPercent,
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
      storage: getIt.get(),
      baseNeural: widget.projenitorNeural,
      individualsCount: widget.individualsCount,
    );
    if (getIt.isRegistered<GenerationManager>()) {
      getIt.unregister<GenerationManager>();
    }
    getIt.registerSingleton(_generationManager);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget gameWidget = NeuralGame(
      onReady: (value) {
        game = value;
      },
    );
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: OrientationBuilder(builder: (context, orientation) {
          switch (orientation) {
            case Orientation.landscape:
              return Row(
                children: [
                  TrainPanelWidget(
                    withGraph: widget.train,
                    onTapStart: _onStart,
                    orientation: orientation,
                    onTapGenerateSpikes: _onGenerateSpikes,
                  ),
                  Expanded(
                    child: gameWidget,
                  ),
                ],
              );
            case Orientation.portrait:
              return Column(
                children: [
                  TrainPanelWidget(
                    withGraph: widget.train,
                    onTapStart: _onStart,
                    orientation: orientation,
                    onTapGenerateSpikes: _onGenerateSpikes,
                  ),
                  Expanded(
                    child: gameWidget,
                  ),
                ],
              );
          }
        }),
      ),
    );
  }

  void _onStart() {
    _generationManager.generateInitPosition();
    if (!widget.train) {
      game?.query<Knight>().forEach((element) => element.removeFromParent());
    }
    game?.add(
      widget.train
          ? _generationManager
          : Knight(
              position: _generationManager.initPosition,
              neuralnetWork: widget.projenitorNeural!,
              training: false,
              onWin: () {}),
    );
  }

  void _onGenerateSpikes() {
    game?.query<SpikesLine>().forEach((element) => element.reset());
  }
}
