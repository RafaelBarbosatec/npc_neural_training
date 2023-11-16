import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:npc_neural/game/components/finish_line.dart';
import 'package:npc_neural/game/components/spikes_line.dart';

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
              'finish_line': (properties) => FinishLine(
                    position: properties.position,
                    size: properties.size,
                  ),
              // 'spikes': (properties) => Spikes(
              //       position: properties.position,
              //     ),
              'spikes_line': (properties) => SpikesLine(
                    position: properties.position,
                  ),
            },
          ),
          onReady: onReady,
          cameraConfig: CameraConfig(
            moveOnlyMapArea: true,
            initialMapZoomFit: InitialMapZoomFitEnum.fitWidth,
          ),
        );
      },
    );
  }
}
