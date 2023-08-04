import 'dart:math';

import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/chest.dart';
import 'package:npc_neural/game/components/spikes.dart';
import 'package:npc_neural/game/npc_neural_game.dart';

class NeuralGame extends StatelessWidget {
  final ValueChanged<BonfireGameInterface> onReady;
  const NeuralGame({super.key, required this.onReady});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BonfireWidget(
          map: WorldMapByTiled(
            'map/map.tmj',
            objectsBuilder: {
              'target': (properties) => Chest(
                    position: properties.position,
                  ),
              'spikes': (properties) => Spikes(
                    position: properties.position,
                  ),
            },
          ),
          onReady: onReady,
          cameraConfig: CameraConfig(
            moveOnlyMapArea: true,
            zoom: getZoomGame(
              constraints.biggest,
              NpcNeuralGame.tilesize,
              25,
            ),
          ),
        );
      },
    );
  }

  double getZoomGame(Size screenSize, double tileSize, int maxTile) {
    final maxSize = max(screenSize.width, screenSize.height);
    return maxSize / (tileSize * maxTile);
  }
}
