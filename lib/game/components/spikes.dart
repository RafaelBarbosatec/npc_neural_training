import 'package:bonfire/bonfire.dart';
import 'package:npc_neural/game/npc_neural_game.dart';
import 'package:npc_neural/util/spritesheet.dart';

class Spikes extends GameDecoration with DragGesture {
  Spikes({
    required super.position,
  }) : super.withAnimation(
          size: Vector2.all(16),
          animation: Spritesheet.spikes,
        );

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size, isSolid: true));
    return super.onLoad();
  }

  @override
  void onEndDrag(int pointer) {
    double restX = x % NpcNeuralGame.tilesize;
    double restY = y % NpcNeuralGame.tilesize;
    if (restX < NpcNeuralGame.tilesize / 2) {
      restX = -restX;
    } else {
      restX = NpcNeuralGame.tilesize - restX;
    }

    if (restY < NpcNeuralGame.tilesize / 2) {
      restY = -restY;
    } else {
      restY = NpcNeuralGame.tilesize - restY;
    }

    position += Vector2(
      restX,
      restY,
    );

    super.onCancelDrag(pointer);
  }
}
