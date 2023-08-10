import 'package:bonfire/bonfire.dart';
import 'package:npc_neural/game/components/finish_line_tile.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/util/spritesheet.dart';

class FinishLine extends GameDecoration {
  late ShapeHitbox hitbox;
  FinishLine({
    required super.position,
    required super.size,
  });

  @override
  Future<void> onLoad() async {
    int countTiles = size.y ~/ NpcNeuralGame.tilesize;
    final sp = await Spritesheet.finishLine;
    final spInv = await Spritesheet.finishLineInverted;
    List.generate(
      countTiles,
      (index) {
        add(
          FinishLineTile(
            position: Vector2(0, NpcNeuralGame.tilesize * index),
            sprite: index % 2 == 0 ? sp : spInv,
          ),
        );
      },
    );
    add(
      hitbox = RectangleHitbox(
        size: size,
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
